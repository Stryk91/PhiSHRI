# PhiSync Multi-Agent Testing & Validation Guide

**Domain 8: Comprehensive Testing Framework for Distributed Agent Systems**

**Version:** 1.0.0
**Last Updated:** 2025-11-15
**Research Base:** 2024-2025 Multi-Agent Testing Methodologies
**Target:** PhiVector Agent Ecosystem (WEBC, DC, VSSC, KALIC)

---

## Table of Contents

1. [Executive Overview](#executive-overview)
2. [Multi-Agent Testing Architecture](#multi-agent-testing-architecture)
3. [Integration Testing Patterns](#integration-testing-patterns)
4. [Property-Based Testing](#property-based-testing)
5. [Contract Testing](#contract-testing)
6. [Mock Agent Implementations](#mock-agent-implementations)
7. [Scenario Simulation](#scenario-simulation)
8. [Performance Benchmarking](#performance-benchmarking)
9. [PhiVector Workflow Test Patterns](#phivector-workflow-test-patterns)
10. [CI/CD Integration](#cicd-integration)
11. [Advanced Testing Strategies](#advanced-testing-strategies)
12. [Troubleshooting & Best Practices](#troubleshooting--best-practices)

---

## Executive Overview

### Purpose

This guide provides comprehensive testing strategies for multi-agent systems in the PhiVector ecosystem, covering the full spectrum from unit tests to distributed integration testing. Modern multi-agent systems require novel approaches to testing that account for:

- **Asynchronous communication** between autonomous agents
- **Emergent behaviors** from agent interactions
- **Cascading failures** where errors in one agent propagate
- **Non-deterministic outcomes** from parallel execution
- **Protocol compliance** (MCP, A2A standards)

### Key Challenges (2024-2025 Research)

1. **Error Propagation**: Errors in one agent can spread, leading to cascading malfunctions, especially when using shared models
2. **Coordination Complexity**: Task coordination becomes challenging without proper architecture and clear communication protocols
3. **State Management**: Distributed state across multiple agents requires sophisticated testing approaches
4. **Protocol Standardization**: MCP (Anthropic, May 2024) and A2A (Google, May 2025) provide new standards for testing

### Testing Pyramid for Multi-Agent Systems

```
         ┌─────────────────┐
         │   E2E Multi-    │  ← Full workflow tests (5%)
         │   Agent Tests   │
         ├─────────────────┤
         │   Integration   │  ← Agent-to-agent tests (15%)
         │   Tests         │
         ├─────────────────┤
         │   Contract      │  ← Protocol/interface tests (30%)
         │   Tests         │
         ├─────────────────┤
         │   Unit Tests    │  ← Individual agent logic (50%)
         │   + Mocks       │
         └─────────────────┘
```

---

## Multi-Agent Testing Architecture

### Testing Framework Components

```yaml
testing_architecture:
  layers:
    - unit_testing:
        scope: Individual agent logic
        tools: [pytest, unittest, jest]
        mocking: Required for external dependencies
        coverage_target: 80%+

    - contract_testing:
        scope: Agent-to-agent interfaces
        tools: [pact, spring-cloud-contract]
        protocols: [MCP, A2A]
        validation: Schema and behavior

    - integration_testing:
        scope: Multi-agent workflows
        tools: [testcontainers, docker-compose]
        environment: Isolated test cluster
        data: Synthetic and anonymized production

    - e2e_testing:
        scope: Complete system flows
        tools: [selenium, playwright, cypress]
        scenarios: Real-world use cases
        monitoring: Performance and correctness

  cross_cutting:
    - property_based_testing:
        tool: hypothesis (Python), fast-check (JS)
        focus: Invariant validation

    - chaos_testing:
        tool: chaos-monkey, toxiproxy
        focus: Resilience and fault tolerance

    - performance_testing:
        tool: locust, k6, jmeter
        metrics: [latency, throughput, resource_usage]
```

### Test Environment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Test Orchestrator                       │
│  (Manages test execution, coordination, reporting)       │
└───────────┬─────────────────────────────────────────────┘
            │
    ┌───────┴────────┐
    │                │
┌───▼────┐     ┌────▼─────┐     ┌──────────┐
│ Agent  │◄────┤  Message │────►│  Agent   │
│ Under  │     │  Bus     │     │  Mock    │
│ Test   │     │  (Test)  │     │  (Stub)  │
└───┬────┘     └────┬─────┘     └──────────┘
    │               │
    │         ┌─────▼──────┐
    │         │  Test DB   │
    │         │  (Isolated)│
    │         └────────────┘
    │
┌───▼──────────────┐
│ Assertion Engine │
│ - State checks   │
│ - Behavior verify│
│ - Performance    │
└──────────────────┘
```

---

## Integration Testing Patterns

### Pattern 1: Synchronous Request-Response Testing

**Use Case:** Testing KALIC → VSSC vulnerability notification

```python
# test_kalic_vssc_integration.py
import pytest
from typing import Dict, List
from phivector.agents import KALIC, VSSC
from phivector.testing import AgentTestHarness, MessageCapture

class TestKALICVSSCIntegration:
    """
    Integration tests for KALIC vulnerability detection
    and VSSC remediation coordination
    """

    @pytest.fixture
    def test_harness(self):
        """Set up isolated test environment"""
        harness = AgentTestHarness()
        harness.register_agent("kalic", KALIC(config={
            "scan_mode": "test",
            "severity_threshold": "medium"
        }))
        harness.register_agent("vssc", VSSC(config={
            "auto_fix": False,  # Prevent actual fixes in test
            "validation_required": True
        }))
        harness.start()
        yield harness
        harness.teardown()

    def test_vulnerability_detection_notification(self, test_harness):
        """
        Test that KALIC properly notifies VSSC of detected vulnerabilities

        Workflow:
        1. KALIC scans test codebase
        2. Detects known vulnerability (injected)
        3. Sends MCP notification to VSSC
        4. VSSC acknowledges and queues for remediation
        """
        # Arrange: Inject known vulnerability
        vuln_code = '''
        def execute_query(user_input):
            query = f"SELECT * FROM users WHERE name = '{user_input}'"
            return db.execute(query)  # SQL Injection vulnerability
        '''
        test_file = test_harness.create_temp_file(
            "vulnerable.py",
            vuln_code
        )

        # Act: Trigger KALIC scan
        kalic = test_harness.get_agent("kalic")
        scan_result = kalic.scan_file(test_file)

        # Capture message traffic
        messages = test_harness.capture_messages(
            from_agent="kalic",
            to_agent="vssc",
            timeout=5.0
        )

        # Assert: Verify notification sent
        assert len(messages) == 1, "Expected exactly one notification"

        notification = messages[0]
        assert notification["type"] == "vulnerability_detected"
        assert notification["severity"] == "high"
        assert "SQL Injection" in notification["description"]
        assert notification["file_path"] == test_file
        assert "line_number" in notification

        # Assert: Verify VSSC received and acknowledged
        vssc = test_harness.get_agent("vssc")
        vssc_queue = vssc.get_remediation_queue()
        assert len(vssc_queue) == 1
        assert vssc_queue[0]["vulnerability_id"] == notification["id"]

        # Assert: Verify state consistency
        assert test_harness.verify_state_consistency([
            ("kalic.detected_vulns", "vssc.queued_vulns")
        ])

    def test_vulnerability_remediation_feedback_loop(self, test_harness):
        """
        Test complete vulnerability remediation cycle with feedback

        Workflow:
        1. KALIC detects vulnerability
        2. VSSC proposes fix
        3. KALIC validates proposed fix
        4. VSSC applies fix
        5. KALIC re-scans to verify
        """
        # Arrange
        vuln_file = test_harness.create_temp_file(
            "app.py",
            "eval(user_input)  # Code injection vulnerability"
        )

        kalic = test_harness.get_agent("kalic")
        vssc = test_harness.get_agent("vssc")

        # Act: Full remediation cycle
        with test_harness.message_trace() as trace:
            # Step 1: Detection
            kalic.scan_file(vuln_file)

            # Step 2: VSSC proposes fix
            test_harness.wait_for_message(
                from_agent="vssc",
                message_type="fix_proposal",
                timeout=10.0
            )

            # Step 3: KALIC validates
            validation_msg = test_harness.wait_for_message(
                from_agent="kalic",
                message_type="fix_validation",
                timeout=5.0
            )

            assert validation_msg["status"] == "approved"

            # Step 4: VSSC applies
            vssc.apply_approved_fixes()

            # Step 5: KALIC re-scans
            rescan_result = kalic.scan_file(vuln_file)

        # Assert: Verify complete workflow
        assert rescan_result["vulnerabilities"] == []
        assert trace.message_count() == 4  # detect, propose, validate, confirm
        assert trace.verify_sequence([
            ("kalic", "vssc", "vulnerability_detected"),
            ("vssc", "kalic", "fix_proposal"),
            ("kalic", "vssc", "fix_validation"),
            ("vssc", "kalic", "fix_applied")
        ])

    @pytest.mark.performance
    def test_high_volume_vulnerability_processing(self, test_harness):
        """
        Test system performance under high vulnerability load

        Validates:
        - Message queue doesn't overflow
        - Response times stay within SLA
        - No message loss
        - Proper prioritization
        """
        # Arrange: Create 100 files with varying vulnerabilities
        vuln_files = []
        for i in range(100):
            severity = ["low", "medium", "high", "critical"][i % 4]
            code = test_harness.generate_vuln_code(severity)
            vuln_files.append(
                test_harness.create_temp_file(f"vuln_{i}.py", code)
            )

        # Act: Scan all files
        kalic = test_harness.get_agent("kalic")

        start_time = time.time()
        with test_harness.performance_monitor() as monitor:
            kalic.scan_files(vuln_files)

            # Wait for all processing to complete
            test_harness.wait_until_idle(timeout=60.0)

        end_time = time.time()

        # Assert: Performance SLAs
        total_time = end_time - start_time
        assert total_time < 30.0, "Processing should complete in <30s"

        # Verify all vulnerabilities processed
        vssc = test_harness.get_agent("vssc")
        processed = vssc.get_processed_count()
        assert processed == 100, f"Expected 100 processed, got {processed}"

        # Verify prioritization (critical processed first)
        processing_order = vssc.get_processing_order()
        critical_indices = [i for i, sev in enumerate(processing_order)
                           if sev == "critical"]
        assert max(critical_indices) < 30, "Critical vulns should be in first 30%"

        # Verify no message loss
        assert monitor.messages_sent == monitor.messages_received
        assert monitor.messages_dropped == 0
```

### Pattern 2: Asynchronous Event-Driven Testing

**Use Case:** Testing DC orchestration of multiple research agents

```python
# test_dc_orchestration.py
import asyncio
import pytest
from phivector.agents import DC, WEBC
from phivector.testing import AsyncAgentTestHarness, EventCollector

class TestDCOrchestration:
    """
    Tests for DC (Deployment Codex) orchestrating multiple WEBC agents
    """

    @pytest.fixture
    async def async_harness(self):
        """Set up async test environment"""
        harness = AsyncAgentTestHarness()

        # Register DC orchestrator
        await harness.register_agent("dc", DC(config={
            "max_parallel_tasks": 5,
            "task_timeout": 30.0
        }))

        # Register 3 WEBC research agents
        for i in range(3):
            await harness.register_agent(
                f"webc_{i}",
                WEBC(config={
                    "research_domains": [i*3, i*3+1, i*3+2],
                    "output_format": "markdown"
                })
            )

        await harness.start()
        yield harness
        await harness.teardown()

    @pytest.mark.asyncio
    async def test_parallel_research_coordination(self, async_harness):
        """
        Test DC coordinating 3 WEBC agents for parallel research

        Workflow:
        1. DC receives research request (9 domains)
        2. DC splits into 3 tasks (3 domains each)
        3. DC assigns to WEBC_0, WEBC_1, WEBC_2
        4. Agents research in parallel
        5. DC aggregates results
        6. DC synthesizes final report
        """
        # Arrange
        research_request = {
            "topic": "Multi-Agent Coordination Patterns",
            "domains": list(range(1, 10)),  # Domains 1-9
            "deadline": "2025-11-15T18:00:00Z"
        }

        event_collector = EventCollector()
        async_harness.attach_observer(event_collector)

        # Act
        dc = await async_harness.get_agent("dc")
        result = await dc.execute_research(research_request)

        # Assert: Verify task distribution
        task_assignments = event_collector.get_events("task_assigned")
        assert len(task_assignments) == 3

        # Verify each WEBC got 3 domains
        for i in range(3):
            assignment = next(
                t for t in task_assignments
                if t["agent"] == f"webc_{i}"
            )
            assert len(assignment["domains"]) == 3
            assert set(assignment["domains"]) == set(range(i*3+1, i*3+4))

        # Assert: Verify parallel execution
        start_times = [t["timestamp"] for t in task_assignments]
        time_spread = max(start_times) - min(start_times)
        assert time_spread < 1.0, "Tasks should start nearly simultaneously"

        # Assert: Verify result aggregation
        assert "aggregated_research" in result
        assert len(result["aggregated_research"]) == 9

        # Verify all domains covered
        covered_domains = set(
            r["domain"] for r in result["aggregated_research"]
        )
        assert covered_domains == set(range(1, 10))

        # Assert: Verify synthesis quality
        assert "final_synthesis" in result
        assert len(result["final_synthesis"]) > 5000  # Substantial content
        assert result["status"] == "completed"

    @pytest.mark.asyncio
    async def test_agent_failure_recovery(self, async_harness):
        """
        Test DC handling WEBC agent failure mid-research

        Simulates:
        - WEBC_1 crashes after starting research
        - DC detects failure
        - DC reassigns task to WEBC_2
        - Overall research completes successfully
        """
        # Arrange
        research_request = {
            "topic": "Failure Recovery Patterns",
            "domains": [1, 2, 3],
            "deadline": "2025-11-15T18:00:00Z"
        }

        dc = await async_harness.get_agent("dc")
        webc_1 = await async_harness.get_agent("webc_1")

        # Inject failure after 2 seconds
        async_harness.schedule_failure(
            agent="webc_1",
            delay=2.0,
            failure_type="crash"
        )

        # Act
        with async_harness.failure_monitor() as monitor:
            result = await dc.execute_research(research_request)

        # Assert: Verify failure detected
        failures = monitor.get_failures()
        assert len(failures) == 1
        assert failures[0]["agent"] == "webc_1"
        assert failures[0]["detected_by"] == "dc"

        # Assert: Verify task reassignment
        reassignments = monitor.get_reassignments()
        assert len(reassignments) == 1
        assert reassignments[0]["from"] == "webc_1"
        assert reassignments[0]["to"] in ["webc_0", "webc_2"]

        # Assert: Verify successful completion despite failure
        assert result["status"] == "completed"
        assert len(result["aggregated_research"]) == 3
        assert result["metadata"]["had_failures"] == True
        assert result["metadata"]["recovery_strategy"] == "reassignment"

    @pytest.mark.asyncio
    async def test_fan_out_fan_in_pattern(self, async_harness):
        """
        Test DC fan-out/fan-in orchestration pattern

        Pattern:
        1. Fan-out: DC sends same query to all 3 WEBC agents
        2. Parallel: Each agent researches independently
        3. Fan-in: DC collects and synthesizes diverse perspectives
        """
        # Arrange
        query = "What are best practices for agent coordination?"

        # Act: Fan-out
        dc = await async_harness.get_agent("dc")

        fan_out_tasks = await dc.fan_out(
            query=query,
            agents=["webc_0", "webc_1", "webc_2"],
            strategy="diverse_perspectives"
        )

        # Wait for all to complete
        results = await asyncio.gather(*fan_out_tasks)

        # Act: Fan-in
        synthesized = await dc.fan_in(
            results=results,
            synthesis_strategy="consensus_with_alternatives"
        )

        # Assert: Verify all agents participated
        assert len(results) == 3
        assert all(r["status"] == "completed" for r in results)

        # Assert: Verify diverse perspectives captured
        unique_sources = set()
        for r in results:
            unique_sources.update(r["sources"])

        assert len(unique_sources) >= 10, "Should have diverse sources"

        # Assert: Verify synthesis quality
        assert "consensus" in synthesized
        assert "alternative_views" in synthesized
        assert len(synthesized["consensus"]) > 500

        # Verify synthesis references all agent inputs
        for i in range(3):
            assert f"webc_{i}" in synthesized["attribution"]
```

### Pattern 3: Scatter-Gather Testing

**Use Case:** DC distributing file analysis across multiple agents

```python
# test_scatter_gather.py
import pytest
from phivector.agents import DC, KALIC
from phivector.testing import AgentTestHarness

class TestScatterGatherPattern:
    """
    Test DC scattering analysis tasks and gathering results
    """

    @pytest.fixture
    def harness_with_multiple_kalics(self):
        """Set up DC with 4 KALIC analysis agents"""
        harness = AgentTestHarness()

        harness.register_agent("dc", DC())

        # Register 4 KALIC agents (one per severity level)
        for severity in ["low", "medium", "high", "critical"]:
            harness.register_agent(
                f"kalic_{severity}",
                KALIC(config={"focus": severity})
            )

        harness.start()
        yield harness
        harness.teardown()

    def test_scatter_files_gather_vulnerabilities(
        self,
        harness_with_multiple_kalics
    ):
        """
        Test scattering 100 files across 4 KALIC agents
        """
        # Arrange: Create 100 test files
        test_files = []
        for i in range(100):
            test_files.append(
                harness_with_multiple_kalics.create_temp_file(
                    f"file_{i}.py",
                    harness_with_multiple_kalics.generate_test_code(i)
                )
            )

        # Act: Scatter
        dc = harness_with_multiple_kalics.get_agent("dc")

        scatter_result = dc.scatter(
            operation="vulnerability_scan",
            items=test_files,
            agents=["kalic_low", "kalic_medium", "kalic_high", "kalic_critical"],
            strategy="round_robin"  # or "load_balanced", "specialty_based"
        )

        # Assert: Verify distribution
        assert scatter_result["total_items"] == 100
        assert scatter_result["agents_used"] == 4
        assert scatter_result["items_per_agent"] == [25, 25, 25, 25]

        # Act: Gather
        gathered = dc.gather(
            scatter_id=scatter_result["id"],
            timeout=60.0,
            aggregation_strategy="merge_and_deduplicate"
        )

        # Assert: Verify gathering
        assert gathered["status"] == "completed"
        assert gathered["results_collected"] == 4
        assert "vulnerabilities" in gathered["aggregated"]

        # Verify no duplicate vulnerabilities
        vuln_ids = [v["id"] for v in gathered["aggregated"]["vulnerabilities"]]
        assert len(vuln_ids) == len(set(vuln_ids)), "Should have no duplicates"
```

---

## Property-Based Testing

### Introduction to Property-Based Testing for Agents

Property-based testing validates **invariants** that should hold true regardless of input data. Instead of testing specific examples, we define properties and let the testing framework generate hundreds of test cases.

### Core Properties for Multi-Agent Systems

```python
# properties.py
from hypothesis import given, strategies as st
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant
from phivector.agents import DC, WEBC

class MultiAgentInvariants:
    """
    Universal properties that should hold for all agent interactions
    """

    @staticmethod
    def message_ordering_preserved(message_log):
        """
        Property: Messages from agent A to agent B should be received
        in the order they were sent (FIFO)
        """
        for sender, receiver in message_log.unique_pairs():
            sent = message_log.get_sent(sender, receiver)
            received = message_log.get_received(receiver, sender)

            # Filter to matching message IDs
            received_ids = [m.id for m in received]
            sent_ids = [m.id for m in sent if m.id in received_ids]

            assert sent_ids == received_ids, \
                f"Message ordering violated for {sender}->{receiver}"

    @staticmethod
    def no_message_loss(message_log, allowed_failures=0):
        """
        Property: All messages sent should be received (unless system
        is in failure mode)
        """
        total_sent = message_log.count_sent()
        total_received = message_log.count_received()
        total_lost = total_sent - total_received

        assert total_lost <= allowed_failures, \
            f"Lost {total_lost} messages, allowed {allowed_failures}"

    @staticmethod
    def state_consistency(agent_cluster):
        """
        Property: After all agents reach idle state, their shared
        state should be consistent
        """
        agent_cluster.wait_until_idle()

        state_snapshots = {
            agent.name: agent.get_state_snapshot()
            for agent in agent_cluster.agents
        }

        # Check key consistency constraints
        for key in agent_cluster.shared_state_keys:
            values = [s[key] for s in state_snapshots.values() if key in s]
            assert len(set(values)) == 1, \
                f"Inconsistent state for key {key}: {values}"

    @staticmethod
    def monotonic_progress(execution_trace):
        """
        Property: Total work completed should never decrease
        """
        work_completed = [t.total_completed for t in execution_trace]

        for i in range(1, len(work_completed)):
            assert work_completed[i] >= work_completed[i-1], \
                f"Work completed decreased at step {i}"
```

### Example: Property-Based Testing with Hypothesis

```python
# test_properties.py
import pytest
from hypothesis import given, strategies as st, settings
from phivector.agents import WEBC
from phivector.testing import AgentTestHarness

class TestWEBCProperties:
    """
    Property-based tests for WEBC research agent
    """

    @given(
        research_topic=st.text(min_size=10, max_size=200),
        num_domains=st.integers(min_value=1, max_value=10)
    )
    @settings(max_examples=100, deadline=5000)  # 100 random test cases
    def test_research_output_always_valid_markdown(
        self,
        research_topic,
        num_domains
    ):
        """
        Property: WEBC output should always be valid Markdown,
        regardless of input topic or domain count
        """
        # Arrange
        harness = AgentTestHarness()
        webc = harness.register_agent("webc", WEBC())
        harness.start()

        try:
            # Act
            result = webc.research(
                topic=research_topic,
                domains=list(range(1, num_domains + 1))
            )

            # Assert: Output is valid Markdown
            assert self._is_valid_markdown(result["output"])

            # Assert: Output is non-empty
            assert len(result["output"]) > 0

            # Assert: Contains required sections
            assert "# " in result["output"]  # Has headers

        finally:
            harness.teardown()

    @given(
        file_paths=st.lists(
            st.text(min_size=1, max_size=100),
            min_size=0,
            max_size=50
        )
    )
    def test_kalic_scan_never_crashes(self, file_paths):
        """
        Property: KALIC should never crash, even with invalid file paths
        Should handle gracefully with error messages
        """
        harness = AgentTestHarness()
        kalic = harness.register_agent("kalic", KALIC())
        harness.start()

        try:
            # Act - should not raise exception
            result = kalic.scan_files(file_paths)

            # Assert: Always returns a result structure
            assert isinstance(result, dict)
            assert "status" in result
            assert result["status"] in ["success", "partial", "error"]

            # Assert: Errors are captured, not raised
            if result["status"] == "error":
                assert "error_message" in result
                assert "failed_files" in result

        except Exception as e:
            pytest.fail(f"KALIC crashed with exception: {e}")

        finally:
            harness.teardown()

    @staticmethod
    def _is_valid_markdown(text):
        """Validate Markdown structure"""
        import markdown
        try:
            markdown.markdown(text)
            return True
        except:
            return False
```

### Stateful Property Testing

```python
# test_stateful_properties.py
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant
from hypothesis import strategies as st
from phivector.agents import DC, WEBC
from phivector.testing import AgentTestHarness

class DCOrchestrationStateMachine(RuleBasedStateMachine):
    """
    Stateful property testing: Simulate random sequences of
    operations and verify invariants always hold
    """

    def __init__(self):
        super().__init__()
        self.harness = AgentTestHarness()
        self.dc = self.harness.register_agent("dc", DC())
        self.tasks = {}
        self.completed_tasks = set()
        self.harness.start()

    @rule(
        task_id=st.text(min_size=1, max_size=20),
        domains=st.lists(st.integers(1, 10), min_size=1, max_size=5)
    )
    def submit_task(self, task_id, domains):
        """Rule: Submit a new research task"""
        if task_id not in self.tasks:
            self.dc.submit_task({
                "id": task_id,
                "domains": domains,
                "topic": f"Research for {task_id}"
            })
            self.tasks[task_id] = {
                "domains": domains,
                "status": "submitted"
            }

    @rule(task_id=st.sampled_from([]))  # Will sample from self.tasks
    def check_status(self, task_id):
        """Rule: Check task status"""
        if task_id in self.tasks:
            status = self.dc.get_task_status(task_id)

            # Update local tracking
            if status["status"] == "completed":
                self.completed_tasks.add(task_id)
                self.tasks[task_id]["status"] = "completed"

    @rule()
    def cancel_random_task(self):
        """Rule: Cancel a random pending task"""
        pending = [
            tid for tid, t in self.tasks.items()
            if t["status"] == "submitted"
        ]
        if pending:
            task_id = pending[0]
            self.dc.cancel_task(task_id)
            del self.tasks[task_id]

    @invariant()
    def task_count_consistency(self):
        """
        Invariant: DC's task count should match our tracking
        """
        dc_task_count = self.dc.get_total_tasks()
        local_count = len(self.tasks)
        assert dc_task_count == local_count, \
            f"DC reports {dc_task_count} tasks, we track {local_count}"

    @invariant()
    def no_duplicate_task_ids(self):
        """
        Invariant: DC should never accept duplicate task IDs
        """
        dc_task_ids = self.dc.get_all_task_ids()
        assert len(dc_task_ids) == len(set(dc_task_ids)), \
            "DC has duplicate task IDs"

    @invariant()
    def completed_tasks_immutable(self):
        """
        Invariant: Once a task is completed, its status should not change
        """
        for task_id in self.completed_tasks:
            status = self.dc.get_task_status(task_id)
            assert status["status"] == "completed", \
                f"Task {task_id} was completed but now shows {status['status']}"

    def teardown(self):
        """Clean up after testing"""
        self.harness.teardown()

# Run the stateful test
TestDCOrchestration = DCOrchestrationStateMachine.TestCase
```

---

## Contract Testing

### MCP (Model Context Protocol) Contract Testing

**Background:** Anthropic introduced MCP in May 2024 as a standardized interface for agents to access tools and resources.

```python
# test_mcp_contracts.py
import pytest
from pact import Consumer, Provider, Like, EachLike
from phivector.agents import WEBC, DC

class TestMCPContracts:
    """
    Contract tests for MCP protocol compliance between agents
    """

    @pytest.fixture
    def pact(self):
        """Set up Pact contract testing"""
        return Consumer('DC').has_pact_with(Provider('WEBC'))

    def test_mcp_resource_request_contract(self, pact):
        """
        Contract: DC requests resource from WEBC via MCP

        MCP Resource Request Format (May 2024 spec):
        {
          "jsonrpc": "2.0",
          "method": "resources/read",
          "params": {
            "uri": "research://domain/5"
          },
          "id": 1
        }
        """
        expected_request = {
            "jsonrpc": "2.0",
            "method": "resources/read",
            "params": {
                "uri": Like("research://domain/5")
            },
            "id": Like(1)
        }

        expected_response = {
            "jsonrpc": "2.0",
            "result": {
                "contents": [
                    {
                        "uri": "research://domain/5",
                        "mimeType": "text/markdown",
                        "text": Like("# Research Results...")
                    }
                ]
            },
            "id": 1
        }

        (pact
         .given('WEBC has research for domain 5')
         .upon_receiving('a request for domain 5 research')
         .with_request('post', '/mcp/resources/read',
                      body=expected_request)
         .will_respond_with(200, body=expected_response))

        # Execute test
        with pact:
            dc = DC()
            result = dc.request_resource("research://domain/5")

            assert result["contents"][0]["mimeType"] == "text/markdown"
            assert len(result["contents"][0]["text"]) > 0

    def test_mcp_tool_invocation_contract(self, pact):
        """
        Contract: DC invokes WEBC research tool via MCP

        MCP Tool Call Format:
        {
          "jsonrpc": "2.0",
          "method": "tools/call",
          "params": {
            "name": "research",
            "arguments": {
              "topic": "multi-agent testing",
              "depth": "comprehensive"
            }
          },
          "id": 2
        }
        """
        expected_request = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "research",
                "arguments": {
                    "topic": Like("multi-agent testing"),
                    "depth": Like("comprehensive")
                }
            },
            "id": Like(2)
        }

        expected_response = {
            "jsonrpc": "2.0",
            "result": {
                "content": [
                    {
                        "type": "text",
                        "text": Like("Research findings...")
                    }
                ],
                "isError": False
            },
            "id": 2
        }

        (pact
         .given('WEBC research tool is available')
         .upon_receiving('a tool invocation request')
         .with_request('post', '/mcp/tools/call',
                      body=expected_request)
         .will_respond_with(200, body=expected_response))

        with pact:
            dc = DC()
            result = dc.invoke_tool(
                "research",
                {"topic": "multi-agent testing", "depth": "comprehensive"}
            )

            assert result["isError"] is False
            assert len(result["content"]) > 0
```

### A2A (Agent-to-Agent) Contract Testing

**Background:** Google introduced A2A protocol in May 2025 for structured inter-agent communication.

```python
# test_a2a_contracts.py
import pytest
from phivector.agents import KALIC, VSSC
from phivector.protocols import A2AValidator

class TestA2AContracts:
    """
    Contract tests for A2A protocol (Google, May 2025)
    """

    def test_a2a_task_delegation_contract(self):
        """
        Contract: KALIC delegates remediation task to VSSC via A2A

        A2A Task Delegation Format:
        {
          "protocol": "a2a/v1",
          "messageType": "task.delegate",
          "sender": {"agentId": "kalic-001", "role": "auditor"},
          "receiver": {"agentId": "vssc-001", "role": "implementer"},
          "task": {
            "taskId": "fix-sql-injection-1",
            "taskType": "vulnerability.remediation",
            "priority": "high",
            "payload": {...}
          },
          "expectations": {
            "deadline": "2025-11-15T18:00:00Z",
            "statusUpdates": "required"
          }
        }
        """
        validator = A2AValidator()

        # Arrange: Create task delegation message
        delegation_msg = {
            "protocol": "a2a/v1",
            "messageType": "task.delegate",
            "sender": {"agentId": "kalic-001", "role": "auditor"},
            "receiver": {"agentId": "vssc-001", "role": "implementer"},
            "task": {
                "taskId": "fix-sql-injection-1",
                "taskType": "vulnerability.remediation",
                "priority": "high",
                "payload": {
                    "vulnerability": {
                        "type": "SQL Injection",
                        "file": "app/db.py",
                        "line": 42,
                        "severity": "critical"
                    },
                    "suggestedFix": "Use parameterized queries"
                }
            },
            "expectations": {
                "deadline": "2025-11-15T18:00:00Z",
                "statusUpdates": "required"
            }
        }

        # Assert: Message conforms to A2A schema
        assert validator.validate(delegation_msg) is True

        # Act: VSSC receives and acknowledges
        vssc = VSSC()
        ack = vssc.receive_a2a_message(delegation_msg)

        # Assert: Acknowledgment conforms to A2A schema
        expected_ack_structure = {
            "protocol": "a2a/v1",
            "messageType": "task.acknowledged",
            "sender": {"agentId": "vssc-001"},
            "receiver": {"agentId": "kalic-001"},
            "taskId": "fix-sql-injection-1",
            "estimatedCompletion": str  # ISO 8601 timestamp
        }

        assert validator.validate(ack) is True
        assert ack["messageType"] == "task.acknowledged"
        assert ack["taskId"] == "fix-sql-injection-1"

    def test_a2a_status_update_contract(self):
        """
        Contract: VSSC sends progress updates to KALIC via A2A
        """
        validator = A2AValidator()

        status_update = {
            "protocol": "a2a/v1",
            "messageType": "task.statusUpdate",
            "sender": {"agentId": "vssc-001"},
            "receiver": {"agentId": "kalic-001"},
            "taskId": "fix-sql-injection-1",
            "status": "in_progress",
            "progress": 0.60,
            "details": {
                "currentStep": "Testing proposed fix",
                "nextStep": "Applying fix to codebase"
            },
            "timestamp": "2025-11-15T14:30:00Z"
        }

        # Assert: Valid status update
        assert validator.validate(status_update) is True

        # Assert: Progress is between 0 and 1
        assert 0 <= status_update["progress"] <= 1

        # Assert: Status is valid enum value
        valid_statuses = [
            "pending", "in_progress", "completed", "failed", "cancelled"
        ]
        assert status_update["status"] in valid_statuses
```

---

## Mock Agent Implementations

### Creating Mock Agents for Testing

```python
# mocks.py
from typing import Dict, List, Any, Optional
from phivector.agents.base import BaseAgent

class MockWEBC(BaseAgent):
    """
    Mock WEBC agent for testing DC orchestration
    without actual web research
    """

    def __init__(self, config: Optional[Dict] = None):
        super().__init__(config or {})
        self.research_calls = []
        self.predefined_responses = {}

    def set_response(self, topic: str, response: Dict):
        """Pre-define response for a topic"""
        self.predefined_responses[topic] = response

    async def research(self, topic: str, domains: List[int]) -> Dict:
        """Mock research method"""
        self.research_calls.append({"topic": topic, "domains": domains})

        if topic in self.predefined_responses:
            return self.predefined_responses[topic]

        # Default mock response
        return {
            "status": "completed",
            "output": f"# Mock Research: {topic}\n\n" +
                     f"Researched domains: {domains}\n\n" +
                     f"This is mock research content for testing.",
            "sources": [f"mock://source/{d}" for d in domains],
            "metadata": {
                "agent": "MockWEBC",
                "timestamp": self.get_timestamp()
            }
        }

    def get_call_count(self) -> int:
        """Return number of times research was called"""
        return len(self.research_calls)

    def assert_called_with(self, topic: str, domains: List[int]):
        """Assert research was called with specific parameters"""
        matching_calls = [
            c for c in self.research_calls
            if c["topic"] == topic and c["domains"] == domains
        ]
        assert len(matching_calls) > 0, \
            f"Expected call with topic='{topic}', domains={domains}"


class MockKALIC(BaseAgent):
    """
    Mock KALIC agent that returns predefined vulnerabilities
    """

    def __init__(self, vulnerabilities: List[Dict] = None):
        super().__init__()
        self.vulnerabilities = vulnerabilities or []
        self.scan_calls = []

    def scan_file(self, file_path: str) -> Dict:
        """Mock vulnerability scan"""
        self.scan_calls.append(file_path)

        return {
            "file": file_path,
            "vulnerabilities": [
                v for v in self.vulnerabilities
                if v.get("file") == file_path
            ],
            "timestamp": self.get_timestamp()
        }

    def scan_files(self, file_paths: List[str]) -> Dict:
        """Mock batch scanning"""
        results = []
        for path in file_paths:
            results.append(self.scan_file(path))

        return {
            "scanned_files": len(file_paths),
            "results": results,
            "total_vulnerabilities": sum(
                len(r["vulnerabilities"]) for r in results
            )
        }


class SpyAgent(BaseAgent):
    """
    Spy wrapper that records all interactions with an agent
    """

    def __init__(self, wrapped_agent: BaseAgent):
        super().__init__()
        self.wrapped = wrapped_agent
        self.messages_sent = []
        self.messages_received = []
        self.method_calls = []

    def send_message(self, recipient: str, message: Dict):
        """Intercept and record outgoing messages"""
        self.messages_sent.append({
            "recipient": recipient,
            "message": message,
            "timestamp": self.get_timestamp()
        })
        return self.wrapped.send_message(recipient, message)

    def receive_message(self, sender: str, message: Dict):
        """Intercept and record incoming messages"""
        self.messages_received.append({
            "sender": sender,
            "message": message,
            "timestamp": self.get_timestamp()
        })
        return self.wrapped.receive_message(sender, message)

    def __getattr__(self, name):
        """Intercept all method calls"""
        attr = getattr(self.wrapped, name)

        if callable(attr):
            def wrapper(*args, **kwargs):
                self.method_calls.append({
                    "method": name,
                    "args": args,
                    "kwargs": kwargs,
                    "timestamp": self.get_timestamp()
                })
                return attr(*args, **kwargs)
            return wrapper

        return attr
```

### Using Mocks in Tests

```python
# test_with_mocks.py
import pytest
from mocks import MockWEBC, MockKALIC, SpyAgent
from phivector.agents import DC

class TestDCWithMocks:
    """
    Test DC orchestration using mock agents
    """

    def test_dc_coordinates_mock_webcs(self):
        """
        Test DC can coordinate mock WEBC agents
        """
        # Arrange: Create mock agents
        webc_1 = MockWEBC()
        webc_1.set_response("AI Testing", {
            "status": "completed",
            "output": "# AI Testing Research\n\nMock content here.",
            "sources": ["mock://ai-testing/1"]
        })

        webc_2 = MockWEBC()
        webc_2.set_response("AI Testing", {
            "status": "completed",
            "output": "# AI Testing Research\n\nDifferent perspective.",
            "sources": ["mock://ai-testing/2"]
        })

        # Create DC with mock agents
        dc = DC()
        dc.register_subordinate("webc_1", webc_1)
        dc.register_subordinate("webc_2", webc_2)

        # Act: Coordinate research
        result = dc.coordinate_research(
            topic="AI Testing",
            agents=["webc_1", "webc_2"]
        )

        # Assert: Both mocks were called
        assert webc_1.get_call_count() == 1
        assert webc_2.get_call_count() == 1

        # Assert: Results aggregated
        assert "aggregated" in result
        assert len(result["aggregated"]["sources"]) == 2

    def test_kalic_vssc_with_spy(self):
        """
        Test KALIC → VSSC interaction using spy pattern
        """
        # Arrange: Create real VSSC wrapped in spy
        real_vssc = VSSC()
        spy_vssc = SpyAgent(real_vssc)

        # Create mock KALIC with predefined vulnerabilities
        mock_kalic = MockKALIC(vulnerabilities=[
            {
                "file": "app.py",
                "type": "SQL Injection",
                "severity": "critical",
                "line": 42
            }
        ])

        # Act: KALIC scans and notifies VSSC
        scan_result = mock_kalic.scan_file("app.py")

        for vuln in scan_result["vulnerabilities"]:
            spy_vssc.receive_notification({
                "type": "vulnerability_detected",
                "details": vuln
            })

        # Assert: Spy recorded the interaction
        assert len(spy_vssc.messages_received) == 1
        assert spy_vssc.messages_received[0]["message"]["type"] == \
            "vulnerability_detected"
```

---

## Scenario Simulation

### Complex Multi-Agent Scenarios

```python
# test_scenarios.py
import pytest
from phivector.testing import ScenarioRunner, AgentCluster

class TestComplexScenarios:
    """
    End-to-end scenario testing for multi-agent workflows
    """

    def test_full_vulnerability_remediation_pipeline(self):
        """
        Scenario: Complete vulnerability detection and remediation

        Steps:
        1. KALIC detects vulnerability in codebase
        2. KALIC notifies DC of critical vulnerability
        3. DC escalates to VSSC for remediation
        4. VSSC proposes fix
        5. DC coordinates review by KALIC
        6. KALIC validates fix is secure
        7. VSSC applies approved fix
        8. KALIC re-scans to verify remediation
        9. DC generates audit report
        """
        runner = ScenarioRunner()

        # Set up agents
        cluster = AgentCluster()
        cluster.add_agent("kalic", KALIC())
        cluster.add_agent("dc", DC())
        cluster.add_agent("vssc", VSSC())

        # Load scenario
        scenario = runner.load_scenario("vulnerability_remediation_pipeline")

        # Execute
        result = runner.run(scenario, cluster, timeout=120.0)

        # Assert: All steps completed
        assert result["status"] == "success"
        assert result["steps_completed"] == 9
        assert result["steps_failed"] == 0

        # Assert: Vulnerability remediated
        final_scan = cluster.get_agent("kalic").scan_file("app.py")
        assert len(final_scan["vulnerabilities"]) == 0

        # Assert: Audit trail generated
        audit = cluster.get_agent("dc").get_audit_log()
        assert "vulnerability_detected" in [e["type"] for e in audit]
        assert "fix_applied" in [e["type"] for e in audit]
        assert "remediation_verified" in [e["type"] for e in audit]

    def test_parallel_research_synthesis_scenario(self):
        """
        Scenario: DC orchestrates 3 WEBC agents for parallel research

        Steps:
        1. User submits research request (9 domains)
        2. DC analyzes and creates execution plan
        3. DC spawns 3 WEBC agents
        4. DC distributes domains (3 each)
        5. WEBC agents research in parallel
        6. DC monitors progress
        7. DC collects results as agents complete
        8. DC synthesizes final report
        9. DC presents to user
        """
        runner = ScenarioRunner()

        cluster = AgentCluster()
        cluster.add_agent("dc", DC())
        # WEBC agents will be spawned dynamically

        scenario = runner.load_scenario("parallel_research_synthesis")
        scenario.set_parameter("num_domains", 9)
        scenario.set_parameter("num_agents", 3)

        # Execute
        with runner.monitor() as monitor:
            result = runner.run(scenario, cluster, timeout=180.0)

        # Assert: Execution successful
        assert result["status"] == "success"

        # Assert: Parallelism achieved
        parallelism = monitor.calculate_parallelism()
        assert parallelism >= 2.5, "Should have ~3x parallelism"

        # Assert: All domains covered
        final_report = result["final_report"]
        assert len(final_report["domains_covered"]) == 9

    def test_agent_failure_and_recovery_scenario(self):
        """
        Scenario: Agent fails mid-task and system recovers

        Steps:
        1. DC assigns task to WEBC_1
        2. WEBC_1 starts processing
        3. WEBC_1 crashes (simulated)
        4. DC detects failure via health check
        5. DC marks task as failed
        6. DC reassigns to WEBC_2
        7. WEBC_2 completes task
        8. DC updates status and notifies user
        """
        runner = ScenarioRunner()

        cluster = AgentCluster()
        cluster.add_agent("dc", DC())
        cluster.add_agent("webc_1", WEBC())
        cluster.add_agent("webc_2", WEBC())

        scenario = runner.load_scenario("agent_failure_recovery")
        scenario.inject_failure(
            agent="webc_1",
            at_step=2,
            failure_type="crash"
        )

        # Execute
        result = runner.run(scenario, cluster, timeout=60.0)

        # Assert: Recovery successful
        assert result["status"] == "success"
        assert result["recoveries_performed"] == 1

        # Assert: Task reassigned
        task_log = cluster.get_agent("dc").get_task_log()
        assignments = [e for e in task_log if e["type"] == "task_assigned"]
        assert len(assignments) == 2  # Initial + reassignment
        assert assignments[0]["agent"] == "webc_1"
        assert assignments[1]["agent"] == "webc_2"
```

---

## Performance Benchmarking

### Benchmarking Framework

```python
# benchmarks.py
import time
import statistics
from typing import List, Dict
from phivector.testing import AgentTestHarness

class PerformanceBenchmark:
    """
    Performance benchmarking for multi-agent systems
    """

    def __init__(self, harness: AgentTestHarness):
        self.harness = harness
        self.results = []

    def benchmark_message_throughput(
        self,
        num_messages: int = 1000
    ) -> Dict:
        """
        Measure message throughput between agents
        """
        sender = self.harness.get_agent("agent_a")
        receiver = self.harness.get_agent("agent_b")

        latencies = []

        start_time = time.time()

        for i in range(num_messages):
            msg_start = time.perf_counter()

            sender.send_message(receiver.id, {
                "id": i,
                "payload": "test" * 100  # ~400 bytes
            })

            # Wait for acknowledgment
            ack = receiver.wait_for_message(timeout=1.0)

            msg_end = time.perf_counter()
            latencies.append((msg_end - msg_start) * 1000)  # ms

        end_time = time.time()
        total_time = end_time - start_time

        return {
            "total_messages": num_messages,
            "total_time_seconds": total_time,
            "messages_per_second": num_messages / total_time,
            "latency_ms": {
                "min": min(latencies),
                "max": max(latencies),
                "mean": statistics.mean(latencies),
                "median": statistics.median(latencies),
                "p95": self._percentile(latencies, 0.95),
                "p99": self._percentile(latencies, 0.99)
            }
        }

    def benchmark_task_distribution(
        self,
        num_tasks: int = 100,
        num_agents: int = 4
    ) -> Dict:
        """
        Benchmark DC distributing tasks across multiple agents
        """
        dc = self.harness.get_agent("dc")

        # Prepare tasks
        tasks = [
            {"id": i, "complexity": (i % 3) + 1}
            for i in range(num_tasks)
        ]

        # Measure distribution time
        start_time = time.time()

        distribution = dc.distribute_tasks(tasks, num_agents)

        # Wait for all to complete
        while not dc.all_tasks_complete():
            time.sleep(0.1)

        end_time = time.time()

        total_time = end_time - start_time

        # Analyze distribution fairness
        tasks_per_agent = distribution["tasks_per_agent"]
        load_variance = statistics.variance(tasks_per_agent)

        return {
            "total_tasks": num_tasks,
            "num_agents": num_agents,
            "total_time_seconds": total_time,
            "tasks_per_second": num_tasks / total_time,
            "distribution": {
                "tasks_per_agent": tasks_per_agent,
                "mean": statistics.mean(tasks_per_agent),
                "variance": load_variance,
                "fairness_score": 1.0 - (load_variance / num_tasks)
            }
        }

    def benchmark_agent_spawn_time(
        self,
        num_agents: int = 10
    ) -> Dict:
        """
        Measure time to spawn multiple agents
        """
        spawn_times = []

        for i in range(num_agents):
            start = time.perf_counter()

            agent = self.harness.spawn_agent(
                name=f"webc_{i}",
                agent_type=WEBC
            )

            # Wait for agent to be ready
            agent.wait_until_ready(timeout=5.0)

            end = time.perf_counter()
            spawn_times.append((end - start) * 1000)  # ms

        return {
            "num_agents": num_agents,
            "spawn_time_ms": {
                "min": min(spawn_times),
                "max": max(spawn_times),
                "mean": statistics.mean(spawn_times),
                "median": statistics.median(spawn_times),
                "total": sum(spawn_times)
            }
        }

    @staticmethod
    def _percentile(data: List[float], percentile: float) -> float:
        """Calculate percentile of data"""
        sorted_data = sorted(data)
        index = int(percentile * len(sorted_data))
        return sorted_data[min(index, len(sorted_data) - 1)]


# Example benchmark runner
class BenchmarkRunner:
    """
    Run comprehensive benchmarks and generate report
    """

    def run_all_benchmarks(self) -> Dict:
        """Execute full benchmark suite"""
        harness = AgentTestHarness()

        # Set up test agents
        harness.register_agent("dc", DC())
        harness.register_agent("agent_a", WEBC())
        harness.register_agent("agent_b", WEBC())
        harness.start()

        benchmark = PerformanceBenchmark(harness)

        results = {
            "message_throughput": benchmark.benchmark_message_throughput(1000),
            "task_distribution": benchmark.benchmark_task_distribution(100, 4),
            "agent_spawn": benchmark.benchmark_agent_spawn_time(10)
        }

        harness.teardown()

        return results
```

### Load Testing

```python
# load_tests.py
import pytest
from locust import User, task, between
from phivector.agents import DC, WEBC

class DCLoadTest(User):
    """
    Load test for DC agent using Locust
    """
    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks

    def on_start(self):
        """Set up user session"""
        self.dc = DC(endpoint="http://localhost:8000")

    @task(3)  # Weight: 3x more likely than other tasks
    def submit_research_task(self):
        """Simulate submitting research task"""
        with self.client.post(
            "/api/tasks/submit",
            json={
                "topic": "Multi-Agent Testing",
                "domains": [1, 2, 3],
                "priority": "normal"
            },
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Got status {response.status_code}")

    @task(1)
    def check_task_status(self):
        """Simulate checking task status"""
        if hasattr(self, 'last_task_id'):
            self.client.get(f"/api/tasks/{self.last_task_id}/status")

    @task(1)
    def get_agent_health(self):
        """Simulate health check"""
        self.client.get("/api/health")

# Run with: locust -f load_tests.py --host=http://localhost:8000
```

---

## PhiVector Workflow Test Patterns

### Pattern 1: WEBC Research → DC Synthesis

```python
# phivector_patterns.py

def test_webc_dc_research_synthesis():
    """
    PhiVector Pattern: WEBC parallel research → DC synthesis

    COPY-PASTE READY TEMPLATE
    """
    # Arrange: Set up agent cluster
    harness = AgentTestHarness()

    dc = harness.register_agent("dc", DC())
    webc_1 = harness.register_agent("webc_1", WEBC())
    webc_2 = harness.register_agent("webc_2", WEBC())
    webc_3 = harness.register_agent("webc_3", WEBC())

    harness.start()

    try:
        # Act: DC coordinates research
        research_request = {
            "topic": "Multi-Agent Coordination",
            "domains": list(range(1, 10)),  # 9 domains
            "output_format": "comprehensive_markdown"
        }

        result = dc.coordinate_parallel_research(
            request=research_request,
            agents=["webc_1", "webc_2", "webc_3"]
        )

        # Assert: Verify synthesis quality
        assert result["status"] == "completed"
        assert len(result["synthesis"]) > 10000  # Substantial content
        assert all(
            domain in result["domains_covered"]
            for domain in range(1, 10)
        )

        print("✓ WEBC → DC research synthesis pattern validated")

    finally:
        harness.teardown()
```

### Pattern 2: KALIC Audit → VSSC Fix → Verification

```python
def test_kalic_vssc_audit_fix_verify():
    """
    PhiVector Pattern: KALIC audit → VSSC fix → KALIC verify

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    kalic = harness.register_agent("kalic", KALIC())
    vssc = harness.register_agent("vssc", VSSC())

    harness.start()

    try:
        # Arrange: Create vulnerable file
        vuln_file = harness.create_temp_file(
            "app.py",
            """
def login(username, password):
    query = f"SELECT * FROM users WHERE user='{username}' AND pass='{password}'"
    return db.execute(query)
            """.strip()
        )

        # Act 1: KALIC audits
        audit_result = kalic.audit_file(vuln_file)

        assert len(audit_result["vulnerabilities"]) > 0
        vuln_id = audit_result["vulnerabilities"][0]["id"]

        # Act 2: VSSC fixes
        fix_result = vssc.remediate_vulnerability(vuln_id)

        assert fix_result["status"] == "fixed"

        # Act 3: KALIC verifies
        verify_result = kalic.audit_file(vuln_file)

        # Assert: Vulnerability fixed
        assert len(verify_result["vulnerabilities"]) == 0

        print("✓ KALIC → VSSC → KALIC audit-fix-verify pattern validated")

    finally:
        harness.teardown()
```

### Pattern 3: DC Coordinates Multi-Step Pipeline

```python
def test_dc_multi_step_pipeline():
    """
    PhiVector Pattern: DC orchestrates complex pipeline

    Pipeline:
    1. WEBC researches requirements
    2. VSSC implements code
    3. KALIC audits implementation
    4. VSSC fixes any issues
    5. DC generates deployment docs

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    dc = harness.register_agent("dc", DC())
    webc = harness.register_agent("webc", WEBC())
    vssc = harness.register_agent("vssc", VSSC())
    kalic = harness.register_agent("kalic", KALIC())

    harness.start()

    try:
        # Act: DC orchestrates full pipeline
        pipeline_result = dc.execute_pipeline({
            "name": "Research → Build → Audit → Deploy",
            "steps": [
                {
                    "agent": "webc",
                    "action": "research",
                    "params": {"topic": "Authentication System"}
                },
                {
                    "agent": "vssc",
                    "action": "implement",
                    "params": {"spec": "$step1.output"}
                },
                {
                    "agent": "kalic",
                    "action": "audit",
                    "params": {"code": "$step2.output"}
                },
                {
                    "agent": "vssc",
                    "action": "fix",
                    "params": {"issues": "$step3.vulnerabilities"},
                    "condition": "$step3.vulnerabilities.length > 0"
                },
                {
                    "agent": "dc",
                    "action": "generate_docs",
                    "params": {"code": "$step2.output", "audit": "$step3"}
                }
            ]
        })

        # Assert: Pipeline completed
        assert pipeline_result["status"] == "completed"
        assert pipeline_result["steps_completed"] >= 4

        # Assert: Final output includes all artifacts
        assert "research_output" in pipeline_result["artifacts"]
        assert "implementation" in pipeline_result["artifacts"]
        assert "audit_report" in pipeline_result["artifacts"]
        assert "deployment_docs" in pipeline_result["artifacts"]

        print("✓ DC multi-step pipeline pattern validated")

    finally:
        harness.teardown()
```

### Pattern 4: Fan-Out Research with Aggregation

```python
def test_fan_out_aggregation_pattern():
    """
    PhiVector Pattern: Fan-out query → Aggregate diverse results

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    dc = harness.register_agent("dc", DC())

    # Register multiple WEBC agents
    for i in range(5):
        harness.register_agent(f"webc_{i}", WEBC())

    harness.start()

    try:
        # Act: Fan out same query to all agents
        query = "What are the best practices for agent coordination?"

        fan_out_result = dc.fan_out_query(
            query=query,
            agents=[f"webc_{i}" for i in range(5)],
            aggregation_strategy="diversity_maximization"
        )

        # Assert: All agents responded
        assert len(fan_out_result["responses"]) == 5

        # Assert: Aggregation captures diverse insights
        aggregated = fan_out_result["aggregated"]

        assert "common_themes" in aggregated
        assert "unique_insights" in aggregated
        assert "confidence_scores" in aggregated

        # Verify diversity
        assert len(aggregated["unique_insights"]) >= 10

        print("✓ Fan-out aggregation pattern validated")

    finally:
        harness.teardown()
```

### Pattern 5: File-Based Command Queue

```python
def test_file_based_command_queue():
    """
    PhiVector Pattern: File-based async command queue with response aggregation

    Workflow:
    1. DC writes command files to queue directory
    2. Multiple agents poll and pick up commands
    3. Agents write responses to response directory
    4. DC aggregates responses

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    queue_dir = harness.create_temp_dir("command_queue")
    response_dir = harness.create_temp_dir("responses")

    dc = harness.register_agent("dc", DC(config={
        "queue_dir": queue_dir,
        "response_dir": response_dir
    }))

    # Register 3 worker agents
    for i in range(3):
        harness.register_agent(
            f"worker_{i}",
            WEBC(config={
                "queue_dir": queue_dir,
                "response_dir": response_dir,
                "poll_interval": 0.1
            })
        )

    harness.start()

    try:
        # Act: DC enqueues 10 research commands
        commands = []
        for i in range(10):
            cmd_id = dc.enqueue_command({
                "command": "research",
                "topic": f"Topic {i}",
                "priority": i % 3
            })
            commands.append(cmd_id)

        # Wait for all responses
        responses = dc.wait_for_responses(
            command_ids=commands,
            timeout=30.0
        )

        # Assert: All commands processed
        assert len(responses) == 10
        assert all(r["status"] == "completed" for r in responses)

        # Assert: Load distributed across workers
        worker_loads = dc.get_worker_loads()
        assert len(worker_loads) == 3
        assert all(load > 0 for load in worker_loads.values())

        # Verify fairness (each worker handled 2-5 commands)
        for worker, load in worker_loads.items():
            assert 2 <= load <= 5, f"{worker} handled {load} commands"

        print("✓ File-based command queue pattern validated")

    finally:
        harness.teardown()
```

### Pattern 6: Regression Test After Fix

```python
def test_regression_after_vulnerability_fix():
    """
    PhiVector Pattern: KALIC finds vuln → VSSC fixes → Regression test

    Ensures fix doesn't break existing functionality

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    kalic = harness.register_agent("kalic", KALIC())
    vssc = harness.register_agent("vssc", VSSC())

    harness.start()

    try:
        # Arrange: Create file with vulnerability but working functionality
        original_file = harness.create_temp_file(
            "database.py",
            """
def get_user(user_id):
    # SQL Injection vulnerability but functionally works
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)

def test_get_user():
    user = get_user(123)
    assert user['id'] == 123
    assert 'name' in user
            """.strip()
        )

        # Act 1: Run initial tests (pass)
        initial_tests = harness.run_tests(original_file)
        assert initial_tests["passed"] == 1

        # Act 2: KALIC detects vulnerability
        audit = kalic.audit_file(original_file)
        vuln = audit["vulnerabilities"][0]

        # Act 3: VSSC fixes vulnerability
        vssc.fix_vulnerability(vuln["id"])

        # Act 4: Run regression tests
        regression_tests = harness.run_tests(original_file)

        # Assert: Tests still pass after fix
        assert regression_tests["passed"] == 1
        assert regression_tests["failed"] == 0

        # Assert: Vulnerability fixed
        verify_audit = kalic.audit_file(original_file)
        assert len(verify_audit["vulnerabilities"]) == 0

        print("✓ Regression test pattern validated")

    finally:
        harness.teardown()
```

### Pattern 7: Parallel Data Processing

```python
def test_parallel_data_processing_pattern():
    """
    PhiVector Pattern: DC orchestrates parallel data processing across agents

    Use case: Process 1000 log files in parallel

    COPY-PASTE READY TEMPLATE
    """
    harness = AgentTestHarness()

    dc = harness.register_agent("dc", DC())

    # Register 10 processing agents
    for i in range(10):
        harness.register_agent(
            f"processor_{i}",
            WEBC(config={"mode": "data_processing"})
        )

    harness.start()

    try:
        # Arrange: Generate 1000 data items
        data_items = [
            {"id": i, "payload": f"data_{i}"}
            for i in range(1000)
        ]

        # Act: DC distributes processing
        start_time = time.time()

        result = dc.parallel_process(
            items=data_items,
            processors=[f"processor_{i}" for i in range(10)],
            batch_size=100
        )

        end_time = time.time()

        # Assert: All items processed
        assert result["items_processed"] == 1000
        assert result["items_failed"] == 0

        # Assert: Performance gain from parallelization
        processing_time = end_time - start_time
        assert processing_time < 10.0, "Should complete in <10 seconds"

        # Calculate speedup
        theoretical_serial_time = 1000 * 0.1  # 0.1s per item
        speedup = theoretical_serial_time / processing_time
        assert speedup >= 8.0, f"Should have ~10x speedup, got {speedup}x"

        print(f"✓ Parallel processing pattern validated (speedup: {speedup:.1f}x)")

    finally:
        harness.teardown()
```

---

## CI/CD Integration

### GitHub Actions Integration

```yaml
# .github/workflows/multi-agent-tests.yml
name: Multi-Agent System Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov hypothesis

      - name: Run unit tests
        run: pytest tests/unit --cov=phivector --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  integration-tests:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis:7
        ports:
          - 6379:6379

      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: testpass
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-asyncio

      - name: Start agent cluster
        run: |
          docker-compose -f docker-compose.test.yml up -d
          sleep 10  # Wait for agents to start

      - name: Run integration tests
        run: pytest tests/integration -v --tb=short

      - name: Collect agent logs
        if: failure()
        run: docker-compose -f docker-compose.test.yml logs > agent-logs.txt

      - name: Upload logs
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: agent-logs
          path: agent-logs.txt

  contract-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pact-python

      - name: Run contract tests
        run: pytest tests/contracts -v

      - name: Publish Pact contracts
        if: github.ref == 'refs/heads/main'
        run: |
          pact-broker publish pacts/ \
            --broker-base-url=${{ secrets.PACT_BROKER_URL }} \
            --broker-token=${{ secrets.PACT_BROKER_TOKEN }}

  performance-tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install locust

      - name: Start system
        run: docker-compose up -d

      - name: Run load tests
        run: |
          locust -f tests/load/locustfile.py \
            --headless \
            --users 100 \
            --spawn-rate 10 \
            --run-time 5m \
            --host http://localhost:8000 \
            --html report.html

      - name: Upload performance report
        uses: actions/upload-artifact@v3
        with:
          name: performance-report
          path: report.html

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest playwright
          playwright install

      - name: Start full system
        run: docker-compose -f docker-compose.full.yml up -d

      - name: Wait for system ready
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:8000/health; do sleep 2; done'

      - name: Run E2E tests
        run: pytest tests/e2e -v --video=on --screenshot=on

      - name: Upload test artifacts
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-artifacts
          path: test-results/
```

---

## Advanced Testing Strategies

### Chaos Engineering for Multi-Agent Systems

```python
# chaos_tests.py
import pytest
from phivector.testing import ChaosEngine, AgentCluster

class TestChaosEngineering:
    """
    Chaos engineering tests to validate system resilience
    """

    def test_random_agent_failures(self):
        """
        Inject random agent failures and verify system resilience
        """
        cluster = AgentCluster()
        cluster.add_agents(["dc", "webc_1", "webc_2", "kalic", "vssc"])
        cluster.start()

        chaos = ChaosEngine(cluster)

        # Configure chaos: 20% chance of agent failure every 5 seconds
        chaos.configure({
            "failure_rate": 0.20,
            "failure_interval": 5.0,
            "recovery_time": 10.0
        })

        try:
            # Start chaos monkey
            chaos.start()

            # Run workload under chaos
            dc = cluster.get_agent("dc")

            results = []
            for i in range(20):  # 20 tasks over ~100 seconds
                result = dc.execute_task({
                    "id": i,
                    "action": "research",
                    "topic": f"Topic {i}"
                })
                results.append(result)
                time.sleep(5)

            chaos.stop()

            # Assert: System maintained availability despite failures
            successful = [r for r in results if r["status"] == "completed"]
            success_rate = len(successful) / len(results)

            assert success_rate >= 0.80, \
                f"Success rate {success_rate} below 80% threshold"

            # Assert: Failures were handled gracefully
            failures = chaos.get_failure_log()
            assert len(failures) > 0, "Chaos should have injected failures"

            for failure in failures:
                assert failure["handled"] is True, \
                    f"Failure {failure['id']} was not handled"

        finally:
            chaos.stop()
            cluster.teardown()

    def test_network_partition(self):
        """
        Simulate network partition between agents
        """
        cluster = AgentCluster()
        cluster.add_agents(["dc", "webc_1", "webc_2"])
        cluster.start()

        chaos = ChaosEngine(cluster)

        try:
            # Partition: DC can't communicate with WEBC_1
            chaos.create_network_partition(
                group_a=["dc"],
                group_b=["webc_1"],
                duration=30.0
            )

            # DC should route tasks to WEBC_2 only
            dc = cluster.get_agent("dc")

            task = dc.execute_task({
                "action": "research",
                "topic": "Network Partitions"
            })

            # Assert: Task completed using available agents
            assert task["status"] == "completed"
            assert task["assigned_agent"] == "webc_2"

            # Assert: WEBC_1 marked as unavailable
            agent_status = dc.get_agent_status()
            assert agent_status["webc_1"]["available"] is False
            assert agent_status["webc_2"]["available"] is True

        finally:
            chaos.stop()
            cluster.teardown()

    def test_message_delay_injection(self):
        """
        Inject random message delays to test timeout handling
        """
        cluster = AgentCluster()
        cluster.add_agents(["kalic", "vssc"])
        cluster.start()

        chaos = ChaosEngine(cluster)

        try:
            # Inject delays: 50% of messages delayed by 2-10 seconds
            chaos.inject_latency({
                "probability": 0.50,
                "min_delay": 2.0,
                "max_delay": 10.0
            })

            kalic = cluster.get_agent("kalic")

            # Send message that expects response
            start_time = time.time()

            try:
                result = kalic.send_with_response(
                    recipient="vssc",
                    message={"action": "get_status"},
                    timeout=5.0
                )

                elapsed = time.time() - start_time

                # Assert: Timeout or delayed response
                if result is None:
                    assert elapsed >= 5.0, "Should have timed out"
                else:
                    assert elapsed < 5.0, "Should have received within timeout"

            except TimeoutError:
                # Expected when message is delayed beyond timeout
                pass

        finally:
            chaos.stop()
            cluster.teardown()
```

---

## Troubleshooting & Best Practices

### Common Testing Issues

#### Issue 1: Flaky Tests Due to Timing

**Problem:** Tests fail intermittently due to race conditions

**Solution:**
```python
# Bad: Hard-coded sleep
time.sleep(5)  # Hope 5 seconds is enough

# Good: Wait with condition
harness.wait_until(
    lambda: agent.get_status() == "ready",
    timeout=10.0,
    poll_interval=0.1
)

# Even better: Use event-driven waiting
harness.wait_for_event(
    event_type="agent_ready",
    agent="webc_1",
    timeout=10.0
)
```

#### Issue 2: Test Pollution

**Problem:** Tests affect each other due to shared state

**Solution:**
```python
# Use isolated test environments
@pytest.fixture(scope="function")  # New instance per test
def isolated_harness():
    harness = AgentTestHarness(isolation=True)
    yield harness
    harness.teardown()  # Always clean up

# Or use database transactions
@pytest.fixture
def db_transaction():
    transaction = db.begin()
    yield transaction
    transaction.rollback()  # Discard all changes
```

#### Issue 3: Message Ordering Assumptions

**Problem:** Tests assume FIFO message delivery

**Solution:**
```python
# Bad: Assumes order
msg1 = harness.get_next_message()
msg2 = harness.get_next_message()
assert msg1["type"] == "started"
assert msg2["type"] == "completed"

# Good: Wait for specific messages
started_msg = harness.wait_for_message(message_type="started")
completed_msg = harness.wait_for_message(message_type="completed")

# Verify completed came after started
assert completed_msg["timestamp"] > started_msg["timestamp"]
```

### Best Practices

1. **Test Independence**: Each test should be runnable in isolation
2. **Cleanup**: Always tear down test resources (use try/finally or fixtures)
3. **Timeouts**: Always use timeouts on blocking operations
4. **Determinism**: Use mocks/stubs to eliminate non-determinism
5. **Observability**: Instrument tests with logging and metrics
6. **Fast Feedback**: Keep unit tests fast (<100ms each)
7. **Realistic Data**: Use production-like test data (anonymized)
8. **Contract Tests**: Maintain contract tests for all agent interfaces

### Testing Checklist

- [ ] Unit tests for all agent logic
- [ ] Contract tests for all inter-agent interfaces
- [ ] Integration tests for multi-agent workflows
- [ ] Property-based tests for invariants
- [ ] Performance benchmarks
- [ ] Load tests
- [ ] Chaos engineering tests
- [ ] E2E scenario tests
- [ ] CI/CD pipeline integration
- [ ] Test coverage >= 80%

---

## Conclusion

This comprehensive testing guide provides the foundation for validating multi-agent systems in the PhiVector ecosystem. By combining unit tests, integration tests, property-based testing, contract testing, and chaos engineering, you can ensure your multi-agent system is robust, reliable, and performant.

**Key Takeaways:**

1. **Multi-layered testing** is essential for distributed systems
2. **Property-based testing** catches edge cases traditional tests miss
3. **Contract testing** ensures protocol compliance between agents
4. **Chaos engineering** validates resilience under failure conditions
5. **Performance benchmarking** prevents regressions
6. **CI/CD integration** provides continuous validation

For more patterns and examples, see the companion guides:
- `09_COORDINATION_PATTERNS/REAL_WORLD_COORDINATION_PATTERNS.md`
- `10_LIFECYCLE_MANAGEMENT/AGENT_LIFECYCLE_GUIDE.md`

---

**PhiVector Testing Framework v1.0**
*Building Confidence in Distributed Agent Systems*
