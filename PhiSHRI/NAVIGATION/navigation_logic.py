#!/usr/bin/env python3
"""
PhiSHRI Navigation Logic
Implements the three-layer addressing system for instant context loading
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from difflib import SequenceMatcher

class PhiSHRINavigator:
    """
    The Keymaster - Provides instant context loading through semantic navigation
    """
    
    def __init__(self, base_path: str = "/workspace/PhiSRHI/PhiSHRI"):
        self.base_path = Path(base_path)
        self.semantic_map = self._load_json("INDEXES/SEMANTIC_MAP.json")
        self.hash_table = self._load_json("INDEXES/HASH_TABLE.json")
        self.nlp_patterns = self._load_json("INDEXES/NLP_PATTERNS.json")
        self.error_matcher = self._load_json("INDEXES/ERROR_MATCHER.json")
        self.prerequisites = self._load_json("INDEXES/PREREQUISITES.json")
        self.cache = {}
    
    def _load_json(self, relative_path: str) -> Dict:
        """Load JSON file"""
        file_path = self.base_path / relative_path
        if not file_path.exists():
            return {}
        
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def _is_hash_code(self, query: str) -> bool:
        """Check if query is a hash code"""
        # Hash codes follow pattern: [PREFIX][SEQUENCE][SUFFIX]
        # Examples: 800WINMCP, A01DC, E01PERM
        pattern = r'^[A-Z0-9]{3,10}[A-Z#]*$'
        return bool(re.match(pattern, query.upper()))
    
    def _is_semantic_path(self, query: str) -> bool:
        """Check if query is a semantic path"""
        # Semantic paths follow pattern: CATEGORY.SUBCATEGORY.SPECIFIC
        # Examples: TOOLS.WINDOWS_MCP.FILE_OPERATIONS
        pattern = r'^[A-Z_]+\.[A-Z_]+(\.[A-Z_]+)*$'
        return bool(re.match(pattern, query.upper()))
    
    def _load_door(self, door_code: str) -> Optional[Dict]:
        """Load a door's context bundle"""
        if door_code in self.cache:
            return self.cache[door_code]
        
        # Get file path from hash table
        if door_code not in self.hash_table.get('mappings', {}):
            return None
        
        file_path = self.base_path / self.hash_table['mappings'][door_code]
        
        if not file_path.exists():
            return None
        
        with open(file_path, 'r', encoding='utf-8') as f:
            door = json.load(f)
        
        # Cache the door
        self.cache[door_code] = door
        
        return door
    
    def _load_prerequisites(self, door_code: str, visited: set = None) -> List[Dict]:
        """Load all prerequisite doors recursively with circular dependency detection"""
        if visited is None:
            visited = set()
        
        # Prevent circular dependencies
        if door_code in visited:
            return []
        
        visited.add(door_code)
        loaded = []
        
        # Get prerequisites from graph
        prereqs = self.prerequisites.get('dependency_graph', {}).get(door_code, {}).get('prerequisites', [])
        
        for prereq_code in prereqs:
            # Skip if already visited (circular dependency)
            if prereq_code in visited:
                continue
            
            # Load prerequisite
            prereq_door = self._load_door(prereq_code)
            if prereq_door:
                loaded.append(prereq_door)
                
                # Recursively load prerequisites of prerequisites
                sub_prereqs = self._load_prerequisites(prereq_code, visited)
                loaded.extend(sub_prereqs)
        
        return loaded
    
    def _fuzzy_match(self, query: str, candidates: List[str], threshold: float = 0.6) -> List[Tuple[str, float]]:
        """Fuzzy match query against candidates"""
        matches = []
        query_lower = query.lower()
        
        for candidate in candidates:
            candidate_lower = candidate.lower()
            
            # Calculate similarity
            ratio = SequenceMatcher(None, query_lower, candidate_lower).ratio()
            
            if ratio >= threshold:
                matches.append((candidate, ratio))
        
        # Sort by similarity (highest first)
        matches.sort(key=lambda x: x[1], reverse=True)
        
        return matches
    
    def _nlp_query_match(self, query: str) -> List[Tuple[str, float]]:
        """Match natural language query to door codes"""
        matches = []
        query_lower = query.lower()
        query_words = set(query_lower.split())
        
        # Check each pattern
        for pattern_name, pattern_data in self.nlp_patterns.get('query_patterns', {}).items():
            keywords = set(pattern_data.get('keywords', []))
            contexts = set(pattern_data.get('contexts', []))
            door_codes = pattern_data.get('door_codes', [])
            
            # Calculate keyword match score
            keyword_matches = len(query_words.intersection(keywords))
            context_matches = len(query_words.intersection(contexts))
            
            if keyword_matches > 0 or context_matches > 0:
                # Calculate confidence score
                total_score = (keyword_matches * 2) + context_matches
                max_score = (len(keywords) * 2) + len(contexts)
                confidence = total_score / max_score if max_score > 0 else 0
                
                for door_code in door_codes:
                    matches.append((door_code, confidence))
        
        # Sort by confidence (highest first)
        matches.sort(key=lambda x: x[1], reverse=True)
        
        return matches
    
    def _error_pattern_match(self, error_text: str) -> Optional[Tuple[str, float]]:
        """Match error text to door code"""
        error_lower = error_text.lower()
        
        for pattern_name, pattern_data in self.error_matcher.get('error_patterns', {}).items():
            signatures = pattern_data.get('signatures', [])
            door_code = pattern_data.get('door_code')
            confidence = pattern_data.get('confidence', 0.0)
            
            # Check if any signature matches
            for signature in signatures:
                if signature.lower() in error_lower:
                    return (door_code, confidence)
        
        return None
    
    def find_door(self, query: str, load_prerequisites: bool = True) -> Dict:
        """
        Find and load a door using any of the three addressing methods:
        1. Hash code lookup (e.g., "800WINMCP")
        2. Semantic path (e.g., "TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
        3. Natural language query (e.g., "how to write files on windows")
        """
        result = {
            'query': query,
            'method': None,
            'door_code': None,
            'door': None,
            'prerequisites': [],
            'confidence': 0.0,
            'alternatives': []
        }
        
        # Method 1: Hash code lookup
        if self._is_hash_code(query):
            door_code = query.upper()
            door = self._load_door(door_code)
            
            if door:
                result['method'] = 'hash_code_lookup'
                result['door_code'] = door_code
                result['door'] = door
                result['confidence'] = 1.0
                
                if load_prerequisites:
                    result['prerequisites'] = self._load_prerequisites(door_code)
                
                return result
        
        # Method 2: Semantic path resolution
        if self._is_semantic_path(query):
            semantic_path = query.upper()
            mappings = self.semantic_map.get('mappings', {})
            
            if semantic_path in mappings:
                door_code = mappings[semantic_path]
                door = self._load_door(door_code)
                
                if door:
                    result['method'] = 'semantic_path_resolution'
                    result['door_code'] = door_code
                    result['door'] = door
                    result['confidence'] = 1.0
                    
                    if load_prerequisites:
                        result['prerequisites'] = self._load_prerequisites(door_code)
                    
                    return result
        
        # Method 3: Natural language query
        nlp_matches = self._nlp_query_match(query)
        
        if nlp_matches:
            # Get best match
            door_code, confidence = nlp_matches[0]
            door = self._load_door(door_code)
            
            if door:
                result['method'] = 'natural_language_query'
                result['door_code'] = door_code
                result['door'] = door
                result['confidence'] = confidence
                
                if load_prerequisites:
                    result['prerequisites'] = self._load_prerequisites(door_code)
                
                # Add alternatives
                for alt_code, alt_conf in nlp_matches[1:4]:
                    alt_door = self._load_door(alt_code)
                    if alt_door:
                        result['alternatives'].append({
                            'door_code': alt_code,
                            'confidence': alt_conf,
                            'summary': alt_door['context_bundle']['summary']
                        })
                
                return result
        
        # Method 4: Fuzzy matching as fallback
        all_codes = list(self.hash_table.get('mappings', {}).keys())
        fuzzy_matches = self._fuzzy_match(query, all_codes, threshold=0.5)
        
        if fuzzy_matches:
            door_code, confidence = fuzzy_matches[0]
            door = self._load_door(door_code)
            
            if door:
                result['method'] = 'fuzzy_matching'
                result['door_code'] = door_code
                result['door'] = door
                result['confidence'] = confidence
                
                if load_prerequisites:
                    result['prerequisites'] = self._load_prerequisites(door_code)
                
                return result
        
        # No match found
        result['method'] = 'no_match'
        return result
    
    def find_door_by_error(self, error_text: str, load_prerequisites: bool = True) -> Dict:
        """
        Find door based on error pattern matching
        Enables error-driven navigation
        """
        result = {
            'error_text': error_text,
            'method': 'error_pattern_matching',
            'door_code': None,
            'door': None,
            'prerequisites': [],
            'confidence': 0.0
        }
        
        match = self._error_pattern_match(error_text)
        
        if match:
            door_code, confidence = match
            door = self._load_door(door_code)
            
            if door:
                result['door_code'] = door_code
                result['door'] = door
                result['confidence'] = confidence
                
                if load_prerequisites:
                    result['prerequisites'] = self._load_prerequisites(door_code)
        
        return result
    
    def load_chain(self, chain_name: str) -> Dict:
        """
        Load a predefined chain of doors
        Useful for common workflows
        """
        chains = self.prerequisites.get('loading_chains', {})
        
        if chain_name not in chains:
            return {
                'chain_name': chain_name,
                'found': False,
                'doors': []
            }
        
        chain_data = chains[chain_name]
        door_codes = chain_data.get('doors', [])
        
        doors = []
        for door_code in door_codes:
            door = self._load_door(door_code)
            if door:
                doors.append(door)
        
        return {
            'chain_name': chain_name,
            'found': True,
            'description': chain_data.get('description', ''),
            'total_doors': len(doors),
            'estimated_load_time_ms': chain_data.get('estimated_load_time_ms', 0),
            'doors': doors
        }
    
    def get_onboarding_summary(self, door_code: str) -> str:
        """
        Get quick-start onboarding summary for a door
        """
        door = self._load_door(door_code)
        
        if not door:
            return f"Door {door_code} not found"
        
        bundle = door.get('context_bundle', {})
        onboarding = bundle.get('onboarding', {})
        
        summary = f"# {door_code} - {door.get('semantic_path', '')}\n\n"
        summary += f"{bundle.get('summary', '')}\n\n"
        summary += f"## Quick Start\n{onboarding.get('quick_start', '')}\n\n"
        
        # Add prerequisites
        prereqs = bundle.get('prerequisites', [])
        if prereqs:
            summary += f"## Prerequisites\n"
            for prereq in prereqs:
                summary += f"- {prereq}\n"
            summary += "\n"
        
        # Add common patterns
        patterns = onboarding.get('common_patterns', [])
        if patterns:
            summary += f"## Common Patterns\n"
            for pattern in patterns:
                summary += f"- {pattern}\n"
            summary += "\n"
        
        return summary

def main():
    """Demo the navigation system"""
    nav = PhiSHRINavigator()
    
    print("=" * 60)
    print("PhiSHRI Navigation System Demo")
    print("=" * 60)
    
    # Test 1: Hash code lookup
    print("\n1. Hash Code Lookup: '800WINMCP'")
    result = nav.find_door("800WINMCP")
    print(f"   Method: {result['method']}")
    print(f"   Confidence: {result['confidence']}")
    print(f"   Prerequisites: {len(result['prerequisites'])}")
    
    # Test 2: Semantic path
    print("\n2. Semantic Path: 'AGENTS.DC.COORDINATION'")
    result = nav.find_door("AGENTS.DC.COORDINATION")
    print(f"   Method: {result['method']}")
    print(f"   Confidence: {result['confidence']}")
    print(f"   Door Code: {result['door_code']}")
    
    # Test 3: Natural language
    print("\n3. Natural Language: 'how to write files on windows'")
    result = nav.find_door("how to write files on windows")
    print(f"   Method: {result['method']}")
    print(f"   Confidence: {result['confidence']:.2f}")
    print(f"   Door Code: {result['door_code']}")
    print(f"   Alternatives: {len(result['alternatives'])}")
    
    # Test 4: Error pattern
    print("\n4. Error Pattern: 'PermissionError: [WinError 5] Access is denied'")
    result = nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")
    print(f"   Method: {result['method']}")
    print(f"   Confidence: {result['confidence']}")
    print(f"   Door Code: {result['door_code']}")
    
    # Test 5: Load chain
    print("\n5. Load Chain: 'basic_file_operations'")
    result = nav.load_chain("basic_file_operations")
    print(f"   Found: {result['found']}")
    print(f"   Total Doors: {result['total_doors']}")
    print(f"   Estimated Load Time: {result['estimated_load_time_ms']}ms")
    
    # Test 6: Onboarding summary
    print("\n6. Onboarding Summary: 'A01DC'")
    summary = nav.get_onboarding_summary("A01DC")
    print(summary[:300] + "...")

if __name__ == '__main__':
    main()