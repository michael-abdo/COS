# Form Validation Testing Skill

**Goal:** Automate validation of form fields, error messages, and submission behavior. Use this pattern to test required fields, format validation, submission success, and error recovery across domains.

## Setup

### Prerequisites
- Form is loaded and visible
- Test data: valid and invalid values for each field
- Browser console available for assertion logging

### Example Test Data
```json
{
  "valid": {
    "email": "candidate@example.com",
    "name": "John Doe",
    "phone": "+15039249557"
  },
  "invalid": {
    "email": "not-an-email",
    "phone": "123",
    "name": ""
  }
}
```

## Pattern: Test Required Field Validation

### Automation Steps

1. **Locate the form and get field references**
   ```javascript
   const form = document.querySelector('[data-test=candidate-form]');
   const emailField = form.querySelector('[data-test=email]');
   const nameField = form.querySelector('[data-test=name]');
   const submitButton = form.querySelector('[data-test=submit]');
   ```

2. **Clear all fields**
   ```javascript
   emailField.value = '';
   nameField.value = '';
   emailField.focus(); emailField.blur();  // Trigger validation
   nameField.focus(); nameField.blur();
   ```

3. **Verify error messages appear**
   ```javascript
   const emailError = form.querySelector('[data-error=email]');
   const nameError = form.querySelector('[data-error=name]');
   
   if (emailError && emailError.textContent.includes('required')) {
     console.log('PASS: Email required error shown');
   } else {
     console.log('FAIL: Email required error not shown');
   }
   ```

4. **Submit and verify form is blocked**
   ```javascript
   const disabledBefore = submitButton.disabled;
   if (disabledBefore) {
     console.log('PASS: Submit button disabled when fields invalid');
   } else {
     console.log('FAIL: Submit button should be disabled');
   }
   ```

5. **Fill valid data and verify errors clear**
   ```javascript
   emailField.value = 'valid@example.com';
   nameField.value = 'John Doe';
   emailField.focus(); emailField.blur();
   nameField.focus(); nameField.blur();
   
   const errorsClear = !emailError.textContent && !nameError.textContent;
   if (errorsClear && !submitButton.disabled) {
     console.log('PASS: Errors cleared, submit enabled');
   } else {
     console.log('FAIL: Errors should be cleared');
   }
   ```

6. **Submit and verify success**
   ```javascript
   submitButton.click();
   // Wait for response (see async-assertion-waiting skill)
   setTimeout(() => {
     const successMsg = document.querySelector('[data-test=success]');
     if (successMsg) {
       console.log('PASS: Form submitted, success message shown');
     } else {
       console.log('FAIL: Form submission may have failed');
     }
   }, 1000);
   ```

## Example: Candidate Application Form

### Test Scenario
Validate the candidate application form requires email and name, rejects invalid email, and submits on valid input.

### Automation Code
```javascript
// Initialize
const form = document.querySelector('[data-test=candidate-form]');
const fields = {
  email: form.querySelector('[data-test=email]'),
  name: form.querySelector('[data-test=name]'),
  phone: form.querySelector('[data-test=phone]'),
  submit: form.querySelector('[data-test=submit]')
};

// Test 1: Required field validation
console.log('TEST: Required field validation');
fields.email.value = '';
fields.name.value = '';
fields.email.focus(); fields.email.blur();
fields.name.focus(); fields.name.blur();

const emailError = form.querySelector('[data-error=email]');
const nameError = form.querySelector('[data-error=name]');

if (emailError?.textContent && nameError?.textContent) {
  console.log('PASS: Required field errors shown');
} else {
  console.log('FAIL: Required errors missing');
}

// Test 2: Invalid email format rejection
console.log('TEST: Invalid email format');
fields.email.value = 'not-an-email';
fields.email.focus(); fields.email.blur();

if (form.querySelector('[data-error=email]')?.textContent.includes('valid')) {
  console.log('PASS: Invalid email error shown');
} else {
  console.log('FAIL: Invalid email should be rejected');
}

// Test 3: Valid input clears errors and enables submit
console.log('TEST: Valid input enables submit');
fields.email.value = 'candidate@example.com';
fields.name.value = 'John Doe';
fields.phone.value = '+15039249557';
fields.email.focus(); fields.email.blur();
fields.name.focus(); fields.name.blur();

const hasErrors = Array.from(form.querySelectorAll('[data-error]')).some(e => e.textContent);
if (!hasErrors && !fields.submit.disabled) {
  console.log('PASS: Errors cleared, submit enabled');
} else {
  console.log('FAIL: Form should be valid');
}

// Test 4: Submission success
console.log('TEST: Form submission');
fields.submit.click();
// (Continue with async waiting pattern from async-assertion-waiting skill)
```

## Reusable Code Snippet

Copy this and adapt for your form:

```javascript
function validateForm(formSelector, expectedErrors = []) {
  const form = document.querySelector(formSelector);
  const results = [];

  // Test each expected error field
  for (const errorField of expectedErrors) {
    const field = form.querySelector(`[data-test=${errorField}]`);
    const errorElement = form.querySelector(`[data-error=${errorField}]`);
    
    field.focus();
    field.blur();
    
    if (errorElement && errorElement.textContent) {
      results.push(`PASS: ${errorField} validation error shown`);
    } else {
      results.push(`FAIL: ${errorField} validation error missing`);
    }
  }

  // Log all results
  results.forEach(r => console.log(r));
  
  // Return true if all passed
  return results.every(r => r.includes('PASS'));
}

// Usage:
// validateForm('[data-test=candidate-form]', ['email', 'name', 'phone'])
```

## Cross-Domain Examples

### Hiring: Candidate Application Form
- **Fields:** Email, Name, Phone, Cover Letter
- **Validations:** Email format, required fields, phone length
- **Success:** Confirmation email sent
- **Test file:** `candidate-profile/tests/test-form-validation.mmd`

### Trading: Order Entry Form
- **Fields:** Symbol, Quantity, Price, Order Type
- **Validations:** Symbol exists, quantity > 0, price > 0
- **Success:** Order placed, confirmation shown
- **Test file:** `order-entry/tests/test-form-validation.mmd`

### Engineering: Deployment Form
- **Fields:** Environment, Branch, Version
- **Validations:** Branch exists, version format valid
- **Success:** Deployment initiated, status tracked
- **Test file:** `deployment/tests/test-form-validation.mmd`

## Common Pitfalls

### ❌ Timing Issues
**Problem:** Validation errors don't appear immediately.
**Solution:** Use the async-assertion-waiting skill to poll for error elements.

### ❌ Form Reset Between Tests
**Problem:** Previous test's data affects next test.
**Solution:** Always clear form fields at the start of each test.

### ❌ Hidden Error Messages
**Problem:** Error elements exist but are hidden.
**Solution:** Check both `.textContent` and `.offsetHeight > 0` (element is visible).

### ❌ Submit Button State Not Updated
**Problem:** Button still says "Submit" even when form is invalid.
**Solution:** Check `.disabled` property AND visual state (button color, cursor).
