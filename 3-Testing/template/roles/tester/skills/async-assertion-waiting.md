# Async Assertion Waiting Skill

**Goal:** Handle asynchronous operations in tests by polling for expected states, timeouts, and retry logic. Use this pattern when assertions depend on API responses, animations, debounced updates, or server state changes.

## The Problem: Async Operations Break Tests

When you click a button, the result often doesn't appear immediately. The system might:
- Wait for an API response
- Debounce user input
- Animate a state change
- Sync with a database

If your test assertion runs before the operation completes, the test fails—not because the code is broken, but because the test didn't wait.

## Solution: Polling-Based Assertions

Instead of:
```javascript
// ❌ WRONG: Assertion runs immediately, fails if API still pending
button.click();
console.log(result.textContent);  // "Loading..." → FAIL
```

Use:
```javascript
// ✅ CORRECT: Assertion waits for expected state
button.click();
waitFor(() => result.textContent !== 'Loading...', 5000).then(() => {
  console.log('PASS: Status updated to: ' + result.textContent);
});
```

## Pattern: waitFor() Helper Function

### Core Implementation

```javascript
function waitFor(predicate, timeoutMs = 5000, intervalMs = 100) {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    
    const checkInterval = setInterval(() => {
      try {
        if (predicate()) {
          clearInterval(checkInterval);
          resolve();
        }
      } catch (e) {
        // Predicate threw error, likely element doesn't exist yet
      }
      
      if (Date.now() - startTime > timeoutMs) {
        clearInterval(checkInterval);
        reject(new Error(`Timeout waiting for condition (${timeoutMs}ms)`));
      }
    }, intervalMs);
  });
}
```

### Usage Pattern

```javascript
// Wait for element to appear
waitFor(() => document.querySelector('[data-test=success]') !== null, 5000)
  .then(() => console.log('PASS: Success message appeared'))
  .catch(() => console.log('FAIL: Success message never appeared'));

// Wait for element text to change
const status = document.querySelector('[data-test=status]');
waitFor(() => status.textContent === 'interview', 5000)
  .then(() => console.log('PASS: Status changed to interview'))
  .catch(() => console.log('FAIL: Status still ' + status.textContent));

// Wait for multiple conditions
waitFor(() => {
  const status = document.querySelector('[data-test=status]');
  const updated = document.querySelector('[data-test=updated-at]');
  return status?.textContent === 'interview' && updated?.textContent !== '';
}, 5000)
  .then(() => console.log('PASS: Status and timestamp updated'))
  .catch(() => console.log('FAIL: Not all fields updated'));
```

## Pattern: Polling with Retries

When a single check isn't enough (e.g., test data inconsistency):

```javascript
function waitForWithRetries(predicate, timeoutMs = 5000, maxRetries = 3) {
  return new Promise(async (resolve, reject) => {
    let retries = 0;
    
    const attempt = async () => {
      try {
        await waitFor(predicate, timeoutMs);
        resolve();
      } catch (e) {
        if (retries < maxRetries) {
          retries++;
          console.log(`Retry ${retries}/${maxRetries}`);
          // Wait before retry (e.g., give DB time to sync)
          setTimeout(attempt, 500);
        } else {
          reject(e);
        }
      }
    };
    
    attempt();
  });
}

// Usage: Wait for eventual consistency
waitForWithRetries(() => {
  const dashboard = document.querySelector('[data-test=dashboard]');
  return dashboard?.textContent.includes('John Doe');
}, 5000, 3)
  .then(() => console.log('PASS: Dashboard updated (eventually)'))
  .catch(() => console.log('FAIL: Dashboard never updated'));
```

## Pattern: Wait for Network Response

For API calls, poll the response status:

```javascript
async function waitForApiResponse(fetchPromise, timeoutMs = 5000) {
  const startTime = Date.now();
  
  while (Date.now() - startTime < timeoutMs) {
    try {
      const response = await Promise.race([
        fetchPromise,
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), 500)
        )
      ]);
      return response;
    } catch (e) {
      if (Date.now() - startTime > timeoutMs) throw e;
      // Keep trying
    }
  }
}

// Usage
const formPromise = fetch('/api/candidates', {
  method: 'POST',
  body: JSON.stringify({ name: 'John Doe', email: 'john@example.com' })
});

waitForApiResponse(formPromise, 5000)
  .then(response => {
    if (response.ok) {
      console.log('PASS: Form submitted successfully');
    } else {
      console.log('FAIL: Server returned ' + response.status);
    }
  })
  .catch(() => console.log('FAIL: API request timed out'));
```

## Example: Test with Async State Change

### Scenario
User clicks "Schedule Interview". The system calls an API, updates the database, and broadcasts the change. Status updates arrive asynchronously.

### Test Code

```javascript
// Setup
const candidate = document.querySelector('[data-test=candidate]');
const status = document.querySelector('[data-test=status]');
const scheduleButton = document.querySelector('[data-test=schedule-button]');

console.log('TEST: Schedule interview (async status update)');
console.log('Initial status: ' + status.textContent);  // "cold"

// Action: Click button
scheduleButton.click();
console.log('Button clicked, waiting for status update...');

// Wait for status to change
waitFor(() => status.textContent === 'interview', 5000)
  .then(() => {
    console.log('PASS: Status changed to interview');
    console.log('Final status: ' + status.textContent);
  })
  .catch(() => {
    console.log('FAIL: Status did not update within 5 seconds');
    console.log('Current status: ' + status.textContent);
  });
```

### GIF Recording for Async Tests

For async operations, the GIF must capture:
1. **Action:** Button clicked
2. **Loading state:** Spinner or disabled button (shows system is working)
3. **Result:** Final state when assertion passes

```
START GIF RECORDING

Click "Schedule Interview" button
  → Loading spinner appears
  → Status field updates from "cold" → "interview"

STOP GIF RECORDING (after status is visible)
```

The GIF shows the *entire sequence*, not just the click.

## Cross-Domain Examples

### Hiring: Candidate Status Update
- **Action:** Click "Schedule Interview"
- **Async:** Database update, email sent
- **Assertion:** Status changes from "cold" → "interview"
- **Timeout:** 5 seconds (typical API response)
- **Test file:** `candidate-profile/tests/test-async-status-update.mmd`

### Trading: Order Fill Confirmation
- **Action:** Click "Place Order"
- **Async:** Exchange processes order, returns fill price
- **Assertion:** Balance updates, position appears
- **Timeout:** 2 seconds (market data)
- **Test file:** `order-entry/tests/test-order-fill-async.mmd`

### Engineering: Deployment Status
- **Action:** Click "Deploy to Production"
- **Async:** CI/CD pipeline runs, health checks
- **Assertion:** Status changes from "pending" → "deployed"
- **Timeout:** 30 seconds (deployment pipeline)
- **Test file:** `deployment/tests/test-deployment-async.mmd`

## Common Scenarios and Timeouts

| Scenario | Timeout | Reason |
|----------|---------|--------|
| Button click → element appears | 500ms | DOM is instant |
| Form submission → API response | 2–5 seconds | Network latency |
| Status update → broadcast received | 1–2 seconds | WebSocket or polling |
| Database change → UI refresh | 2–5 seconds | Query + render |
| Deployment → health check pass | 30–60 seconds | CI/CD pipeline |
| File upload → processing | 5–30 seconds | File size dependent |

## Debugging Async Assertion Failures

If `waitFor()` times out:

```javascript
// 1. Check if the element exists at all
const status = document.querySelector('[data-test=status]');
if (!status) {
  console.log('FAIL: Status element does not exist');
}

// 2. Check current value
console.log('Current status: ' + status?.textContent);

// 3. Check if element is visible
console.log('Is visible: ' + (status?.offsetHeight > 0));

// 4. Check if CSS is hiding it
console.log('Display: ' + window.getComputedStyle(status).display);
console.log('Opacity: ' + window.getComputedStyle(status).opacity);

// 5. Lower timeout and check more frequently
waitFor(() => {
  console.log('Polling... current status: ' + status?.textContent);
  return status?.textContent === 'interview';
}, 5000, 200)  // Check every 200ms instead of 100ms
  .then(() => console.log('PASS'))
  .catch(() => console.log('FAIL'));
```

## Anti-Pattern: Blind Sleep

❌ **WRONG:**
```javascript
button.click();
setTimeout(() => {  // Just sleep 2 seconds and hope
  console.log(result.textContent);
}, 2000);
```

Problems:
- Slow if operation finishes in 500ms
- Flaky if operation takes > 2 seconds
- No assertion, just hope

✅ **RIGHT:**
```javascript
button.click();
waitFor(() => result.textContent !== 'Loading...', 5000)
  .then(() => console.log('PASS: ' + result.textContent))
  .catch(() => console.log('FAIL: Never updated'));
```

Benefits:
- Fast: passes as soon as condition is true
- Reliable: waits up to timeout
- Observable: logs what we're waiting for and what we got
