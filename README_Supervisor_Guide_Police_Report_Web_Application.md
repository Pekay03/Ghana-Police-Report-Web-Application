# Ghana Police Report Web Application
## Supervisor Demonstration and User Guide

**Live website:** http://policebackgroundreport.runasp.net/  
**Project:** Design and Development of a Ghana Police Report Web Application  
**Technology:** ASP.NET Web Forms, C#, .NET Framework 4.8, Bootstrap, MySQL/MariaDB  
**Hosting:** MonsterASP.NET

---

## 1. Purpose of this guide

This README gives the project supervisor a simple, step-by-step guide to opening and demonstrating the web application. It describes the main user journeys and suggests checks to carry out during the demonstration.

> **Important:** The website address is provided by the student. The steps below are a demonstration checklist, not a claim that every feature or external integration has already passed a live test.

## 2. Open the website

1. Connect the computer to the internet.
2. Open Chrome, Microsoft Edge, or another modern browser.
3. Enter the website address: http://policebackgroundreport.runasp.net/
4. Wait for the landing page to load.
5. Check that the page displays correctly and that its navigation links work.
6. If the site does not load, record the error and tell the student before continuing.

## 3. Understand the user roles

- **Citizen:** creates an account, signs in, submits a police background-check request, uploads supporting documents where available, and checks application progress.
- **Police Officer:** accesses the officer workspace to review applications assigned to the account and record permitted processing actions.
- **Administrator:** oversees application records, staff/user management, operational information, audit activity, and available administrative modules.

Access should depend on the account's stored role and the application's permissions. A person should not gain staff or administrator access simply by selecting a role on a public page.

## 4. Demonstration A — Citizen journey

1. Open the landing page.
2. Select the registration option.
3. Register a test citizen account using test information approved for the demonstration.
4. Do not use real applicants' Ghana Card numbers, passport details, personal documents, or private contact details for a classroom demonstration.
5. Sign in using the newly created test account.
6. Confirm that the citizen dashboard opens.
7. Open the application submission page.
8. Complete the form with clearly fictional demonstration information.
9. If document upload is available, use a dummy test document only.
10. Submit the test application.
11. Record the application reference shown by the system, if one is provided.
12. Return to the dashboard and check whether the application appears with its current status.
13. Sign out.

**What the supervisor should observe:** whether registration and login work, whether the correct dashboard appears, whether the form validates required fields, and whether the submitted application can be found afterward.

## 5. Demonstration B — Police Officer journey

1. Open the website and sign in with a pre-created test Police Officer account supplied by the student.
2. Confirm that the officer dashboard opens.
3. Locate an application assigned to that test officer.
4. Open its details.
5. Review the information and test documents provided for the demonstration.
6. If the interface allows it, record an authorised review action using the test record.
7. Check whether the application status or workflow history reflects the action.
8. Sign out.

**If no officer test account is available:** ask the student to prepare one before the meeting. Do not attempt to bypass staff-account protections or create an unauthorised staff account on the live website.

## 6. Demonstration C — Administrator journey

1. Open the website and sign in using the administrator test account supplied securely by the student.
2. Confirm that the Admin Dashboard opens.
3. Review the dashboard totals and charts or summaries that are available.
4. Open the application management area and locate the test application submitted during the citizen demonstration.
5. Review the available user/staff management features.
6. Open the audit or activity area, if available, and check whether the demonstration actions have been recorded.
7. Review the identity-document review, payment monitoring, or notification modules only as demonstrations of the functions actually present.
8. Sign out.

**Security:** Do not put administrator passwords in this README, a presentation, a public repository, or a screenshot. The student should provide credentials to the supervisor through a private channel and revoke or change temporary credentials after the demonstration.

## 7. Features to explain carefully

### Identity documents
The system can support a staff member's review of uploaded documents and the recording of a review decision where that feature is implemented. A local comparison or document review is **not the same as official National Identification Authority (NIA) verification**. Do not claim that the application connects to or verifies records through NIA unless an authorised integration has actually been approved, configured, and tested.

### Payments
If the current version uses simulated payment records or a demonstration payment flow, describe it as a prototype/simulated process. Do not claim that real payments are being collected unless the live payment provider configuration and end-to-end transaction have been verified.

### SMS notifications
A message request accepted by an SMS provider does not automatically prove that the message arrived on the recipient's phone. Describe SMS as tested only to the level supported by actual delivery evidence.

### Application decisions and certificates
Demonstrate only the actions that the current deployed version supports. Do not describe a request as officially approved or a certificate as officially valid unless that is the actual result of an authorised process.

## 8. Suggested supervisor test checklist

Mark each item only after performing the test on the live website.

- [ ] Landing page opens.
- [ ] Registration form loads and validates required fields.
- [ ] A test citizen account can register.
- [ ] Citizen login and logout work.
- [ ] Citizen dashboard displays.
- [ ] A test application can be submitted.
- [ ] The submitted application remains available after navigating away and signing in again.
- [ ] Officer test account can log in.
- [ ] Officer can see the appropriate assigned test application.
- [ ] Permitted officer review action is saved.
- [ ] Administrator test account can log in.
- [ ] Admin dashboard and available modules load.
- [ ] Application and user information shown in the dashboard matches the test records.
- [ ] Audit/activity records appear where expected.
- [ ] Access restrictions prevent unauthorised users from opening staff/admin pages.
- [ ] HTTPS works if an HTTPS address is configured and the certificate is active.
- [ ] Any SMS or payment test is recorded separately with its actual outcome.

## 9. If something goes wrong

1. Write down the page address and the action performed just before the error.
2. Take a screenshot that does not expose passwords, personal documents, API keys, or sensitive applicant data.
3. Record the visible error message and the time it happened.
4. Do not repeatedly submit forms if it is unclear whether the first submission was saved.
5. Send the screenshot and details to the student so the application logs, hosting configuration, and database can be checked.

## 10. What the student should prepare before the meeting

- A working internet connection and browser.
- A short explanation of the problem the project addresses, its aim, and its objectives.
- A test citizen account and a fictional application.
- A test Police Officer account with access to the test application.
- A test administrator account.
- Fictional test data and dummy documents only.
- A short explanation of the technology stack and database.
- Evidence of any external integration tests that are claimed to work.
- A list of known limitations and features that still require testing.

Do not share passwords, database credentials, hosting publish profiles, Hubtel API keys, or private configuration files with the README or a public repository.

## 11. Suggested order for the meeting

1. Introduce the project and its purpose.
2. Open the live landing page.
3. Demonstrate citizen registration and application submission.
4. Sign in as the test officer and review the submitted test application.
5. Sign in as the test administrator and show the available oversight modules.
6. Explain access control, document review, and audit history.
7. State clearly which SMS, payment, and official identity-verification integrations have been tested and which remain limited or pending.
8. Invite the supervisor to try the test workflow and record feedback.

## 12. Hosting and technical notes

The application was developed as a classic ASP.NET Web Forms project targeting .NET Framework 4.8. If the site needs to be reconfigured in MonsterASP.NET, select the **.NET Framework 4.x** runtime for classic ASP.NET/Web Forms rather than ASP.NET Core. Keep the database connection string and service credentials private.

For deployment help, consult the MonsterASP.NET guides:

- [Supported technologies and runtime selection](https://help.monsterasp.net/getting-started/first-steps/supported-technologies)
- [Publish your first application](https://help.monsterasp.net/getting-started/first-steps/publish-first-application)
- [Deployment methods](https://help.monsterasp.net/websites/deploy)

---

**Prepared for:** Project Supervisor  
**Project status:** Demonstration guide for the deployed application. Complete the checklist using the live website and update the results to match what was actually tested.
