#!/usr/bin/env python3
"""
PhiSHRI Navigation System Validation Tests
Validates all three addressing methods and system functionality
"""

import sys
import json
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from NAVIGATION.navigation_logic import PhiSHRINavigator

class ValidationTests:
    def __init__(self):
        self.nav = PhiSHRINavigator()
        self.passed = 0
        self.failed = 0
        self.tests = []
    
    def test(self, name: str, condition: bool, message: str = ""):
        """Record test result"""
        if condition:
            self.passed += 1
            status = "✓ PASS"
        else:
            self.failed += 1
            status = "✗ FAIL"
        
        self.tests.append({
            'name': name,
            'status': status,
            'passed': condition,
            'message': message
        })
        
        print(f"{status}: {name}")
        if message:
            print(f"       {message}")
    
    def test_hash_code_lookup(self):
        """Test hash code lookup method"""
        print("\n" + "="*60)
        print("TEST SUITE: Hash Code Lookup")
        print("="*60)
        
        # Test 1: Valid hash code
        result = self.nav.find_door("800WINMCP")
        self.test(
            "Valid hash code lookup",
            result['method'] == 'hash_code_lookup' and result['door'] is not None,
            f"Method: {result['method']}, Door: {result['door_code']}"
        )
        
        # Test 2: Confidence score
        self.test(
            "Hash code confidence is 1.0",
            result['confidence'] == 1.0,
            f"Confidence: {result['confidence']}"
        )
        
        # Test 3: Multiple hash codes
        test_codes = ["A01DC", "P03VECTOR", "E01PERM"]
        all_found = True
        for code in test_codes:
            result = self.nav.find_door(code)
            if not result['door']:
                all_found = False
                break
        
        self.test(
            "Multiple hash codes lookup",
            all_found,
            f"Tested: {', '.join(test_codes)}"
        )
        
        # Test 4: Invalid hash code
        result = self.nav.find_door("INVALID999")
        self.test(
            "Invalid hash code returns no_match",
            result['method'] == 'no_match',
            f"Method: {result['method']}"
        )
    
    def test_semantic_path_resolution(self):
        """Test semantic path resolution method"""
        print("\n" + "="*60)
        print("TEST SUITE: Semantic Path Resolution")
        print("="*60)
        
        # Test 1: Valid semantic path
        result = self.nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
        self.test(
            "Valid semantic path lookup",
            result['method'] == 'semantic_path_resolution' and result['door'] is not None,
            f"Method: {result['method']}, Door: {result['door_code']}"
        )
        
        # Test 2: Confidence score
        self.test(
            "Semantic path confidence is 1.0",
            result['confidence'] == 1.0,
            f"Confidence: {result['confidence']}"
        )
        
        # Test 3: Multiple semantic paths
        test_paths = [
            "AGENTS.DC.COORDINATION",
            "PROJECTS.PHIVECTOR.OVERVIEW",
            "ERRORS.PERMISSIONS.WINDOWS"
        ]
        all_found = True
        for path in test_paths:
            result = self.nav.find_door(path)
            if not result['door']:
                all_found = False
                break
        
        self.test(
            "Multiple semantic paths lookup",
            all_found,
            f"Tested: {len(test_paths)} paths"
        )
        
        # Test 4: Alias resolution
        result = self.nav.find_door("winmcp_files")
        self.test(
            "Alias resolution works",
            result['door'] is not None and result['door_code'] == "800WINMCP",
            f"Alias 'winmcp_files' → {result['door_code']}"
        )
    
    def test_natural_language_query(self):
        """Test natural language query method"""
        print("\n" + "="*60)
        print("TEST SUITE: Natural Language Query")
        print("="*60)
        
        # Test 1: File operations query
        result = self.nav.find_door("how to write files on windows")
        self.test(
            "Natural language query for file operations",
            result['method'] == 'natural_language_query' and result['door_code'] == "800WINMCP",
            f"Query matched: {result['door_code']} (confidence: {result['confidence']:.2f})"
        )
        
        # Test 2: Agent query
        result = self.nav.find_door("desktop claude coordination")
        self.test(
            "Natural language query for agent",
            result['door'] is not None,
            f"Query matched: {result['door_code']} (confidence: {result['confidence']:.2f})"
        )
        
        # Test 3: Alternatives provided
        result = self.nav.find_door("agent coordination")
        self.test(
            "Alternatives provided for ambiguous query",
            len(result['alternatives']) > 0,
            f"Found {len(result['alternatives'])} alternatives"
        )
        
        # Test 4: Confidence scoring
        result = self.nav.find_door("file operations")
        self.test(
            "Confidence score in valid range",
            0.0 <= result['confidence'] <= 1.0,
            f"Confidence: {result['confidence']:.2f}"
        )
    
    def test_error_pattern_matching(self):
        """Test error pattern matching method"""
        print("\n" + "="*60)
        print("TEST SUITE: Error Pattern Matching")
        print("="*60)
        
        # Test 1: Permission error
        result = self.nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")
        self.test(
            "Permission error pattern matching",
            result['door_code'] == "E01PERM",
            f"Error matched: {result['door_code']} (confidence: {result['confidence']})"
        )
        
        # Test 2: Encoding error
        result = self.nav.find_door_by_error("UnicodeDecodeError: 'utf-8' codec can't decode")
        self.test(
            "Encoding error pattern matching",
            result['door_code'] == "E02ENCODE",
            f"Error matched: {result['door_code']} (confidence: {result['confidence']})"
        )
        
        # Test 3: Multiple error signatures
        errors = [
            "Access denied",
            "Permission denied",
            "WinError 5"
        ]
        all_matched = True
        for error in errors:
            result = self.nav.find_door_by_error(error)
            if result['door_code'] != "E01PERM":
                all_matched = False
                break
        
        self.test(
            "Multiple error signatures match same door",
            all_matched,
            f"All {len(errors)} signatures matched E01PERM"
        )
    
    def test_prerequisite_loading(self):
        """Test prerequisite chain loading"""
        print("\n" + "="*60)
        print("TEST SUITE: Prerequisite Loading")
        print("="*60)
        
        # Test 1: Load with prerequisites
        result = self.nav.find_door("A01DC", load_prerequisites=True)
        self.test(
            "Prerequisites loaded for A01DC",
            len(result['prerequisites']) > 0,
            f"Loaded {len(result['prerequisites'])} prerequisites"
        )
        
        # Test 2: Load without prerequisites
        result = self.nav.find_door("A01DC", load_prerequisites=False)
        self.test(
            "No prerequisites loaded when disabled",
            len(result['prerequisites']) == 0,
            "Prerequisites: 0"
        )
        
        # Test 3: Prerequisite chain correctness
        result = self.nav.find_door("A01DC", load_prerequisites=True)
        prereq_codes = [p['door_code'] for p in result['prerequisites']]
        expected = ["810AHK", "820PWSH"]
        
        self.test(
            "Correct prerequisites loaded",
            all(code in prereq_codes for code in expected),
            f"Expected: {expected}, Got: {prereq_codes}"
        )
    
    def test_chain_loading(self):
        """Test predefined chain loading"""
        print("\n" + "="*60)
        print("TEST SUITE: Chain Loading")
        print("="*60)
        
        # Test 1: Valid chain
        result = self.nav.load_chain("basic_file_operations")
        self.test(
            "Valid chain loads successfully",
            result['found'] and result['total_doors'] > 0,
            f"Loaded {result['total_doors']} doors"
        )
        
        # Test 2: Chain contains expected doors
        expected_doors = ["800WINMCP", "E01PERM", "E02ENCODE"]
        door_codes = [d['door_code'] for d in result['doors']]
        
        self.test(
            "Chain contains expected doors",
            all(code in door_codes for code in expected_doors),
            f"Expected: {expected_doors}, Got: {door_codes}"
        )
        
        # Test 3: Invalid chain
        result = self.nav.load_chain("nonexistent_chain")
        self.test(
            "Invalid chain returns not found",
            not result['found'],
            "Chain not found as expected"
        )
        
        # Test 4: Full PhiVector stack
        result = self.nav.load_chain("full_phivector_stack")
        self.test(
            "Full PhiVector stack loads",
            result['found'] and result['total_doors'] >= 5,
            f"Loaded {result['total_doors']} doors"
        )
    
    def test_onboarding_summary(self):
        """Test onboarding summary generation"""
        print("\n" + "="*60)
        print("TEST SUITE: Onboarding Summary")
        print("="*60)
        
        # Test 1: Summary generation
        summary = self.nav.get_onboarding_summary("800WINMCP")
        self.test(
            "Summary generated successfully",
            len(summary) > 0,
            f"Summary length: {len(summary)} characters"
        )
        
        # Test 2: Summary contains key sections
        required_sections = ["Quick Start", "Prerequisites", "Common Patterns"]
        all_present = all(section in summary for section in required_sections)
        
        self.test(
            "Summary contains required sections",
            all_present,
            f"Sections: {', '.join(required_sections)}"
        )
        
        # Test 3: Invalid door code
        summary = self.nav.get_onboarding_summary("INVALID999")
        self.test(
            "Invalid door returns error message",
            "not found" in summary.lower(),
            "Error message returned"
        )
    
    def test_fuzzy_matching(self):
        """Test fuzzy matching fallback"""
        print("\n" + "="*60)
        print("TEST SUITE: Fuzzy Matching")
        print("="*60)
        
        # Test 1: Typo in hash code
        result = self.nav.find_door("winmcp")
        self.test(
            "Fuzzy match for typo",
            result['door'] is not None,
            f"Matched: {result['door_code']} (method: {result['method']})"
        )
        
        # Test 2: Partial match
        result = self.nav.find_door("A01")
        self.test(
            "Fuzzy match for partial code",
            result['door'] is not None,
            f"Matched: {result['door_code']}"
        )
    
    def test_context_bundle_structure(self):
        """Test context bundle structure"""
        print("\n" + "="*60)
        print("TEST SUITE: Context Bundle Structure")
        print("="*60)
        
        result = self.nav.find_door("800WINMCP")
        door = result['door']
        
        # Test 1: Required top-level fields
        required_fields = ['door_code', 'semantic_path', 'aliases', 'context_bundle']
        all_present = all(field in door for field in required_fields)
        
        self.test(
            "Door has required top-level fields",
            all_present,
            f"Fields: {', '.join(required_fields)}"
        )
        
        # Test 2: Context bundle structure
        bundle = door['context_bundle']
        required_bundle_fields = ['summary', 'prerequisites', 'related_doors', 'onboarding', 'resources', 'metadata']
        all_present = all(field in bundle for field in required_bundle_fields)
        
        self.test(
            "Context bundle has required fields",
            all_present,
            f"Fields: {', '.join(required_bundle_fields)}"
        )
        
        # Test 3: Onboarding structure
        onboarding = bundle['onboarding']
        required_onboarding = ['quick_start', 'full_context_path', 'common_patterns', 'known_errors']
        all_present = all(field in onboarding for field in required_onboarding)
        
        self.test(
            "Onboarding has required fields",
            all_present,
            f"Fields: {', '.join(required_onboarding)}"
        )
        
        # Test 4: Metadata structure
        metadata = bundle['metadata']
        required_metadata = ['last_updated', 'confidence', 'tags', 'category', 'subcategory']
        all_present = all(field in metadata for field in required_metadata)
        
        self.test(
            "Metadata has required fields",
            all_present,
            f"Fields: {', '.join(required_metadata)}"
        )
    
    def test_performance(self):
        """Test performance metrics"""
        print("\n" + "="*60)
        print("TEST SUITE: Performance")
        print("="*60)
        
        import time
        
        # Test 1: Hash lookup speed
        start = time.time()
        result = self.nav.find_door("800WINMCP")
        elapsed_ms = (time.time() - start) * 1000
        
        self.test(
            "Hash lookup under 100ms",
            elapsed_ms < 100,
            f"Time: {elapsed_ms:.2f}ms"
        )
        
        # Test 2: Cached lookup speed
        start = time.time()
        result = self.nav.find_door("800WINMCP")  # Should be cached
        elapsed_ms = (time.time() - start) * 1000
        
        self.test(
            "Cached lookup under 10ms",
            elapsed_ms < 10,
            f"Time: {elapsed_ms:.2f}ms"
        )
        
        # Test 3: Chain loading speed
        start = time.time()
        result = self.nav.load_chain("basic_file_operations")
        elapsed_ms = (time.time() - start) * 1000
        
        self.test(
            "Chain loading under 500ms",
            elapsed_ms < 500,
            f"Time: {elapsed_ms:.2f}ms"
        )
    
    def run_all_tests(self):
        """Run all validation tests"""
        print("\n" + "="*60)
        print("PhiSHRI Navigation System Validation")
        print("="*60)
        
        # Run test suites
        self.test_hash_code_lookup()
        self.test_semantic_path_resolution()
        self.test_natural_language_query()
        self.test_error_pattern_matching()
        self.test_prerequisite_loading()
        self.test_chain_loading()
        self.test_onboarding_summary()
        self.test_fuzzy_matching()
        self.test_context_bundle_structure()
        self.test_performance()
        
        # Print summary
        print("\n" + "="*60)
        print("VALIDATION SUMMARY")
        print("="*60)
        print(f"Total Tests: {self.passed + self.failed}")
        print(f"Passed: {self.passed} ✓")
        print(f"Failed: {self.failed} ✗")
        print(f"Success Rate: {(self.passed / (self.passed + self.failed) * 100):.1f}%")
        
        if self.failed > 0:
            print("\nFailed Tests:")
            for test in self.tests:
                if not test['passed']:
                    print(f"  - {test['name']}")
                    if test['message']:
                        print(f"    {test['message']}")
        
        print("\n" + "="*60)
        
        return self.failed == 0

def main():
    """Run validation tests"""
    validator = ValidationTests()
    success = validator.run_all_tests()
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()