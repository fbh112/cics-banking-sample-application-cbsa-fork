# CICS Banking Sample Application (CBSA) - Application Inventory

## Document Overview
**Version:** 1.0
**Last Updated:** 2026-06-02
**Purpose:** Comprehensive inventory of CBSA technical components, their uses, and main application flows

---

## Component Summary

| Component Type | Count | Location |
|----------------|-------|----------|
| **COBOL Programs** | 29 | src/base/cobol_src/ |
| **COBOL Copybooks** | 36 | src/base/cobol_copy/ |
| **BMS Maps** | 9 | src/base/bms_src/ |
| **Java Classes (Liberty)** | 25+ | src/webui/src/main/java/ |
| **Java Projects (Spring Boot)** | 2 | src/Z-OS-Connect-*-Interface/ |
| **React Components** | Multiple | src/bank-application-frontend/src/ |
| **z/OS Connect Services** | 4 | src/zosconnect_artefacts/ |
| **DB2 Tables** | 3 | ACCOUNT, PROCTRAN, CONTROL |
| **VSAM Files** | 2 | CUSTOMER, ABNDFILE |

---

## Table of Contents
1. [Application Architecture Overview](#application-architecture-overview)
2. [Technical Components Inventory](#technical-components-inventory)
3. [Main Application Flows](#main-application-flows)
4. [Data Stores](#data-stores)
5. [Integration Points](#integration-points)

---

## Application Architecture Overview

### Multi-Layer Architecture
CBSA implements a three-tier architecture with multiple user interface options:

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                      │
├─────────────────┬─────────────────┬─────────────────────────┤
│   BMS 3270      │  Carbon React   │   Spring Boot UIs       │
│   Terminal      │   Web UI        │   (Customer/Payment)    │
└────────┬────────┴────────┬────────┴────────┬────────────────┘
         │                 │                 │
         │                 │                 │
         v                 v                 v
┌─────────────────────────────────────────────────────────────┐
│              Application/Business Logic Layer                │
├─────────────────────────────────────────────────────────────┤
│  • CICS Transaction Server (COBOL Programs)                  │
│  • Liberty JVM Server (JCICS API)                           │
│  • z/OS Connect EE (RESTful Services)                       │
└────────┬────────────────────────────────────────────────────┘
         │
         v
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
├─────────────────────────────────────────────────────────────┤
│  • DB2 Database (Accounts, Transactions, Control)           │
│  • VSAM Files (Customer Data, Abend Logs)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Technical Components Inventory

### 1. COBOL Programs (src/base/cobol_src/)

#### 1.1 Menu & Navigation
| Program | Purpose | Key Functions |
|---------|---------|---------------|
| **BNKMENU.cbl** | Main menu controller | Transaction routing, menu display, option validation |

#### 1.2 Account Operations
| Program | Purpose | Key Functions | Data Access |
|---------|---------|---------------|-------------|
| **CREACC.cbl** | Create new account | ENQ/DEQ Named Counter, account number generation, DB2 insert | DB2: ACCOUNT, PROCTRAN tables |
| **DELACC.cbl** | Delete account | Account validation, balance check, DB2 delete | DB2: ACCOUNT table |
| **INQACC.cbl** | Inquire account details | Account lookup, balance retrieval | DB2: ACCOUNT table |
| **INQACCCU.cbl** | Inquire accounts by customer | Customer account list, count accounts | DB2: ACCOUNT table |
| **UPDACC.cbl** | Update account details | Account modification, interest rate updates | DB2: ACCOUNT table |
| **BNK1CAC.cbl** | BMS Create Account UI | Screen handling for account creation | Calls CREACC |
| **BNK1DAC.cbl** | BMS Delete Account UI | Screen handling for account deletion | Calls DELACC |
| **BNK1UAC.cbl** | BMS Update Account UI | Screen handling for account updates | Calls UPDACC |

#### 1.3 Customer Operations
| Program | Purpose | Key Functions | Data Access |
|---------|---------|---------------|-------------|
| **CRECUST.cbl** | Create new customer | ENQ/DEQ Named Counter, customer number generation, credit score integration | VSAM: CUSTOMER file, DB2: CONTROL table |
| **DELCUS.cbl** | Delete customer | Customer validation, account check, VSAM delete | VSAM: CUSTOMER file |
| **INQCUST.cbl** | Inquire customer details | Customer lookup, credit score retrieval | VSAM: CUSTOMER file |
| **UPDCUST.cbl** | Update customer details | Customer modification, address updates | VSAM: CUSTOMER file |
| **BNK1CCA.cbl** | BMS Create Customer UI | Screen handling for customer creation | Calls CRECUST |
| **BNK1CCS.cbl** | BMS Customer Search UI | Customer search interface | Calls INQCUST |
| **BNK1CRA.cbl** | BMS Customer Review UI | Customer detail review | Calls INQCUST |
| **BNK1DCS.cbl** | BMS Delete Customer UI | Screen handling for customer deletion | Calls DELCUS |

#### 1.4 Transaction Processing
| Program | Purpose | Key Functions | Data Access |
|---------|---------|---------------|-------------|
| **DBCRFUN.cbl** | Debit/Credit operations | Balance updates, transaction logging | DB2: ACCOUNT, PROCTRAN tables |
| **XFRFUN.cbl** | Transfer funds | Inter-account transfers, balance validation | DB2: ACCOUNT, PROCTRAN tables |
| **BNK1TFN.cbl** | BMS Transfer Funds UI | Screen handling for fund transfers | Calls XFRFUN |

#### 1.5 Credit Agency Integration
| Program | Purpose | Key Functions |
|---------|---------|---------------|
| **CRDTAGY1.cbl** | Credit agency stub 1 | Returns credit score 100-199 |
| **CRDTAGY2.cbl** | Credit agency stub 2 | Returns credit score 200-299 |
| **CRDTAGY3.cbl** | Credit agency stub 3 | Returns credit score 300-399 |
| **CRDTAGY4.cbl** | Credit agency stub 4 | Returns credit score 400-499 |
| **CRDTAGY5.cbl** | Credit agency stub 5 | Returns credit score 500-599 |

#### 1.6 Utility Programs
| Program | Purpose | Key Functions |
|---------|---------|---------------|
| **ABNDPROC.cbl** | Abend handler | Error logging, abend information capture |
| **BANKDATA.cbl** | Batch data loader | Initial data population for testing |
| **GETCOMPY.cbl** | Get company name | Retrieve bank company name from control table |
| **GETSCODE.cbl** | Get sort code | Retrieve branch sort code |

### 2. BMS Maps (src/base/bms_src/)

| Map | Purpose | Associated Programs |
|-----|---------|---------------------|
| **BNK1MAI.bms** | Main menu screen | BNKMENU |
| **BNK1ACC.bms** | Account inquiry screen | BNK1CAC, BNK1DAC, BNK1UAC |
| **BNK1CAM.bms** | Create account map | BNK1CAC |
| **BNK1CCM.bms** | Create customer map | BNK1CCA |
| **BNK1CDM.bms** | Customer details map | BNK1CCS, BNK1CRA |
| **BNK1DAM.bms** | Delete account map | BNK1DAC |
| **BNK1DCM.bms** | Delete customer map | BNK1DCS |
| **BNK1TFM.bms** | Transfer funds map | BNK1TFN |
| **BNK1UAM.bms** | Update account map | BNK1UAC |

### 3. COBOL Copybooks (src/base/cobol_copy/)

#### 3.1 Data Structure Copybooks
| Copybook | Purpose | Used By |
|----------|---------|---------|
| **ACCOUNT.cpy** | Account record structure | All account programs |
| **CUSTOMER.cpy** | Customer record structure | All customer programs |
| **PROCTRAN.cpy** | Processed transaction structure | Transaction programs |
| **SORTCODE.cpy** | Sort code definitions | Multiple programs |

#### 3.2 Communication Area Copybooks
| Copybook | Purpose | Used By |
|----------|---------|---------|
| **CREACC.cpy** | Create account COMMAREA | CREACC, BNK1CAC |
| **CRECUST.cpy** | Create customer COMMAREA | CRECUST, BNK1CCA |
| **DELACC.cpy** | Delete account COMMAREA | DELACC, BNK1DAC |
| **DELCUS.cpy** | Delete customer COMMAREA | DELCUS, BNK1DCS |
| **INQACC.cpy** | Inquire account COMMAREA | INQACC |
| **INQACCCU.cpy** | Inquire accounts by customer COMMAREA | INQACCCU |
| **INQCUST.cpy** | Inquire customer COMMAREA | INQCUST |
| **UPDACC.cpy** | Update account COMMAREA | UPDACC, BNK1UAC |
| **UPDCUST.cpy** | Update customer COMMAREA | UPDCUST |
| **XFRFUN.cpy** | Transfer funds COMMAREA | XFRFUN, BNK1TFN |
| **PAYDBCR.cpy** | Payment debit/credit COMMAREA | DBCRFUN |

#### 3.3 DB2 Copybooks
| Copybook | Purpose | Used By |
|----------|---------|---------|
| **ACCDB2.cpy** | Account DB2 table structure | Account programs |
| **CONTDB2.cpy** | Control DB2 table structure | Control programs |
| **PROCDB2.cpy** | Processed transaction DB2 structure | Transaction programs |

#### 3.4 Control & Utility Copybooks
| Copybook | Purpose | Used By |
|----------|---------|---------|
| **ABNDINFO.cpy** | Abend information structure | ABNDPROC, error handlers |
| **ACCTCTRL.cpy** | Account control structure | Account programs |
| **CUSTCTRL.cpy** | Customer control structure | Customer programs |
| **CONTROLI.cpy** | Control record interface | Control programs |
| **GETCOMPY.cpy** | Get company interface | GETCOMPY |
| **GETSCODE.cpy** | Get sort code interface | GETSCODE |
| **NEWACCNO.cpy** | New account number structure | CREACC |
| **NEWCUSNO.cpy** | New customer number structure | CRECUST |

### 4. Java Components

#### 4.1 Liberty JVM Server (src/webui/)
**Purpose:** Carbon React UI backend using JCICS API

| Component | Purpose | Technology |
|-----------|---------|------------|
| **AccountsResource.java** | Account REST endpoints | JAX-RS, JCICS |
| **CustomerResource.java** | Customer REST endpoints | JAX-RS, JCICS |
| **ProcessedTransactionResource.java** | Transaction history endpoints | JAX-RS, JCICS |
| **HBankDataAccess.java** | COBOL program invocation | JCICS Channel/Container API |
| **Account.java** (db2) | DB2 account data access | JDBC |
| **Customer.java** (vsam) | VSAM customer data access | JCICS File API |

#### 4.2 Spring Boot - Customer Services (src/Z-OS-Connect-Customer-Services-Interface/)
**Purpose:** Customer management UI via z/OS Connect

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Customer Services App** | Customer CRUD operations | Spring Boot 3.5, z/OS Connect |
| **RESTful Controllers** | HTTP endpoints for customer operations | Spring MVC |
| **Service Layer** | Business logic and z/OS Connect integration | Spring Services |

#### 4.3 Spring Boot - Payment Interface (src/Z-OS-Connect-Payment-Interface/)
**Purpose:** Payment and transaction UI via z/OS Connect

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Payment Interface App** | Debit/credit/transfer operations | Spring Boot 3.5, z/OS Connect |
| **RESTful Controllers** | HTTP endpoints for payment operations | Spring MVC |
| **Service Layer** | Business logic and z/OS Connect integration | Spring Services |

### 5. React Frontend (src/bank-application-frontend/)

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Carbon React UI** | Modern web interface | React 18, Carbon Design System |
| **Account Components** | Account management screens | React Components |
| **Customer Components** | Customer management screens | React Components |
| **Transaction Components** | Transaction processing screens | React Components |

### 6. z/OS Connect Artifacts (src/zosconnect_artefacts/)

| Artifact | Purpose | COBOL Program |
|----------|---------|---------------|
| **CSaccupd.aar** | Account update service | UPDACC |
| **CScustdel.aar** | Customer delete service | DELCUS |
| **inqaccz.aar** | Account inquiry service | INQACC |
| **updcust.aar** | Customer update service | UPDCUST |

---

## Main Application Flows

### Flow 1: Create Customer
```
User Input (BMS/React/Spring Boot)
    ↓
BNK1CCA (BMS) / CustomerResource (Liberty) / Customer Controller (Spring Boot)
    ↓
CRECUST.cbl
    ↓
├─→ ENQ Named Counter (CBSACUST + SortCode)
├─→ Get Next Customer Number from CONTROL table (DB2)
├─→ Link to CRDTAGY* (Credit Score)
├─→ Write CUSTOMER record (VSAM)
├─→ Update CONTROL table (DB2)
└─→ DEQ Named Counter
    ↓
Return Customer Number to User
```

**Key Components:**
- **Input:** Customer name, address, date of birth
- **Named Counter:** CBSACUST + 6-digit sort code
- **Credit Score:** Random selection of CRDTAGY1-5
- **Output:** 10-digit customer number
- **Error Handling:** Rollback counter on failure

### Flow 2: Create Account
```
User Input (BMS/React/Spring Boot)
    ↓
BNK1CAC (BMS) / AccountsResource (Liberty) / Customer Controller (Spring Boot)
    ↓
CREACC.cbl
    ↓
├─→ Link to INQCUST (Validate Customer Exists)
├─→ Link to INQACCCU (Check Account Count < 10)
├─→ Validate Account Type
├─→ ENQ Named Counter (CBSAACCT + SortCode)
├─→ Get Next Account Number from CONTROL table (DB2)
├─→ INSERT into ACCOUNT table (DB2)
├─→ INSERT into PROCTRAN table (DB2)
└─→ DEQ Named Counter
    ↓
Return Account Number to User
```

**Key Components:**
- **Input:** Customer number, account type, interest rate, overdraft limit
- **Named Counter:** CBSAACCT + 6-digit sort code
- **Validation:** Customer exists, max 10 accounts per customer
- **Account Types:** SAVING, CURRENT, MORTGAGE, LOAN, ISA
- **Output:** 8-digit account number
- **Critical Pattern:** Decrement counter before DEQ on DB2 failure

### Flow 3: Transfer Funds
```
User Input (BMS/React/Spring Boot)
    ↓
BNK1TFN (BMS) / AccountsResource (Liberty) / Payment Controller (Spring Boot)
    ↓
XFRFUN.cbl
    ↓
├─→ Validate Source Account (INQACC)
├─→ Validate Target Account (INQACC)
├─→ Check Sufficient Funds
├─→ Link to DBCRFUN (Debit Source Account)
├─→ Link to DBCRFUN (Credit Target Account)
├─→ INSERT into PROCTRAN table (DB2) - 2 records
└─→ Return Success/Failure
    ↓
Display Confirmation to User
```

**Key Components:**
- **Input:** Source account, target account, amount
- **Validation:** Both accounts exist, sufficient funds
- **Transaction:** Atomic debit/credit operation
- **Audit Trail:** Two PROCTRAN records (debit + credit)
- **Output:** Transaction confirmation

### Flow 4: Debit/Credit Account
```
User Input (Payment Interface)
    ↓
Payment Controller (Spring Boot)
    ↓
z/OS Connect → CICS → DBCRFUN.cbl
    ↓
├─→ Validate Account (INQACC)
├─→ Check Balance (for debit operations)
├─→ UPDATE ACCOUNT table (DB2)
│   ├─→ Update AVAILABLE_BALANCE
│   └─→ Update ACTUAL_BALANCE
├─→ INSERT into PROCTRAN table (DB2)
└─→ Return Updated Balance
    ↓
Display Confirmation to User
```

**Key Components:**
- **Input:** Account number, amount, transaction type (debit/credit)
- **Validation:** Account exists, sufficient funds for debit
- **Balance Update:** Both available and actual balances
- **Audit Trail:** PROCTRAN record with timestamp
- **Output:** Updated balance

### Flow 5: Customer Inquiry with Credit Score
```
User Input (BMS/React/Spring Boot)
    ↓
BNK1CCS (BMS) / CustomerResource (Liberty) / Customer Controller (Spring Boot)
    ↓
INQCUST.cbl
    ↓
├─→ READ CUSTOMER record (VSAM)
├─→ Check Credit Score Review Date
├─→ If Review Needed:
│   ├─→ Link to CRDTAGY* (Get New Score)
│   └─→ UPDATE CUSTOMER record (VSAM)
└─→ Return Customer Data + Credit Score
    ↓
Display Customer Details to User
```

**Key Components:**
- **Input:** Customer number
- **Credit Score Refresh:** Automatic if review date passed
- **Credit Agency:** Random CRDTAGY1-5 selection
- **Output:** Customer details, current credit score
- **Review Cycle:** Configurable review period

---

## Data Stores

### DB2 Tables

#### ACCOUNT Table
**Purpose:** Store account information  
**Key:** SORTCODE + ACCOUNT_NUMBER  
**Columns:**
- EYECATCHER (4 chars) - 'ACCT'
- CUST_NO (10 digits)
- SORTCODE (6 digits)
- ACCOUNT_NUMBER (8 digits)
- ACCOUNT_TYPE (8 chars)
- INTEREST_RATE (decimal 4,2)
- OPENED_DATE (8 digits DDMMYYYY)
- OVERDRAFT_LIMIT (9 digits)
- LAST_STMT_DATE (8 digits)
- NEXT_STMT_DATE (8 digits)
- AVAILABLE_BALANCE (decimal 10,2)
- ACTUAL_BALANCE (decimal 10,2)

#### PROCTRAN Table
**Purpose:** Audit trail of all processed transactions  
**Key:** SORTCODE + ACCOUNT_NUMBER + TIMESTAMP  
**Columns:**
- EYECATCHER (4 chars) - 'PROC'
- SORTCODE (6 digits)
- ACCOUNT_NUMBER (8 digits)
- TIMESTAMP_DATE (10 chars DD.MM.YYYY)
- TIMESTAMP_TIME (6 chars HHMMSS)
- REFERENCE (12 chars)
- TYPE (3 chars) - 'TFR', 'DR', 'CR'
- DESCRIPTION (40 chars)
- AMOUNT (decimal 10,2)

#### CONTROL Table
**Purpose:** Store control information and counters  
**Key:** CONTROL_NAME  
**Columns:**
- CONTROL_NAME (32 chars)
- CONTROL_VALUE_NUM (9 digits) - For counters
- CONTROL_VALUE_STR (40 chars) - For text values

**Key Records:**
- Company name
- Sort code
- Customer number counter (per sort code)
- Account number counter (per sort code)

### VSAM Files

#### CUSTOMER File
**Purpose:** Store customer information  
**Key:** SORTCODE + CUSTOMER_NUMBER  
**Structure:**
- EYECATCHER (4 chars) - 'CUST'
- SORTCODE (6 digits)
- CUSTOMER_NUMBER (10 digits)
- NAME (60 chars)
- ADDRESS (160 chars)
- DATE_OF_BIRTH (8 digits DDMMYYYY)
- CREDIT_SCORE (3 digits)
- CS_REVIEW_DATE (8 digits DDMMYYYY)

#### ABNDFILE
**Purpose:** Store abend information for debugging  
**Key:** TASKNO + TIMESTAMP  
**Structure:**
- Task number
- Timestamp
- Abend code
- Program name
- SQLCODE (if applicable)
- Free-form message

---

## Integration Points

### 1. CICS to DB2
**Method:** Embedded SQL (EXEC SQL)  
**Tables:** ACCOUNT, PROCTRAN, CONTROL  
**Operations:** SELECT, INSERT, UPDATE, DELETE  
**Transaction Management:** CICS handles commit/rollback

### 2. CICS to VSAM
**Method:** CICS File Control (EXEC CICS READ/WRITE/UPDATE/DELETE)  
**Files:** CUSTOMER, ABNDFILE  
**Access:** Keyed access via SORTCODE + NUMBER

### 3. Liberty JVM to COBOL
**Method:** JCICS API (Channel/Container)  
**Programs:** All COBOL business logic programs  
**Data Format:** JSON ↔ COMMAREA conversion  
**Transaction:** CICS transaction context maintained

### 4. Spring Boot to COBOL
**Method:** z/OS Connect EE (RESTful API)  
**Programs:** UPDACC, DELCUS, INQACC, UPDCUST  
**Data Format:** JSON ↔ COMMAREA via z/OS Connect transformations  
**Protocol:** HTTP/HTTPS

### 5. React to Liberty
**Method:** RESTful API (HTTP/JSON)  
**Endpoints:** /accounts, /customers, /transactions  
**Authentication:** CICS security integration  
**Protocol:** HTTPS

### 6. Spring Boot to z/OS Connect
**Method:** RESTful API (HTTP/JSON)  
**Services:** Customer Services, Payment Interface  
**Data Format:** JSON request/response  
**Protocol:** HTTPS

---

## Critical Design Patterns

### 1. Named Counter Pattern
**Purpose:** Generate unique sequential numbers (customer, account)  
**Implementation:**
- ENQ resource before reading counter
- Read current value from CONTROL table
- Increment counter
- Perform business operation (DB2 write)
- If operation fails: Decrement counter
- DEQ resource

**Resource Names:**
- Customer: `CBSACUST` + 6-digit sort code
- Account: `CBSAACCT` + 6-digit sort code

### 2. COMMAREA Communication
**Purpose:** Pass data between programs  
**Pattern:**
- Caller populates COMMAREA structure
- EXEC CICS LINK PROGRAM with COMMAREA
- Called program processes and updates COMMAREA
- Caller reads results from COMMAREA

### 3. Channel/Container (Liberty)
**Purpose:** Modern alternative to COMMAREA for Java-COBOL integration  
**Pattern:**
- Create channel and containers
- Put data in containers (JSON format)
- Link to COBOL program
- Get response from containers

### 4. Credit Score Integration
**Purpose:** Simulate external credit agency calls  
**Pattern:**
- Random selection of CRDTAGY1-5
- Each returns different score range
- Periodic refresh based on review date
- Stored in CUSTOMER record

---

## Build and Deployment

### Build Process
1. **React Frontend:** `yarn install && yarn build` → static files
2. **Java Components:** `mvn clean package` → WAR files
3. **COBOL Programs:** Compile via CICS-supplied JCL
4. **BMS Maps:** Assemble via CICS-supplied JCL

### Deployment Sequence
1. **Base COBOL/BMS:** Install CICS resources, DB2 tables, VSAM files
2. **Carbon React UI:** Deploy Liberty JVM server, install WAR
3. **Spring Boot UIs:** Deploy to z/OS Connect, configure services

### Runtime Requirements
- CICS TS 6.1+ with APAR PH60795
- DB2 V12+
- Liberty JVM server (for Carbon React UI)
- z/OS Connect EE (for Spring Boot UIs)
- Java 17

---

## Appendix: File Locations

### Source Code
- COBOL Programs: `src/base/cobol_src/`
- COBOL Copybooks: `src/base/cobol_copy/`
- BMS Maps: `src/base/bms_src/`
- Java Liberty: `src/webui/src/main/java/`
- Java Customer Services: `src/Z-OS-Connect-Customer-Services-Interface/`
- Java Payment: `src/Z-OS-Connect-Payment-Interface/`
- React Frontend: `src/bank-application-frontend/src/`

### Documentation
- Architecture: `doc/CBSA_Architecture_guide.md`
- BMS User Guide: `etc/usage/base/doc/CBSA_BMS_User_Guide.md`
- Carbon React Guide: `etc/usage/carbonReactUI/doc/CBSA_Carbon_React_UI_User_Guide.md`
- Customer Services Guide: `etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md`
- Payment Guide: `etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md`
- RESTful API Guide: `etc/usage/springBoot/doc/CBSA_Restful_API_guide.md`

### Installation
- Base Install: `etc/install/base/doc/README.md`
- Carbon React Install: `etc/install/carbonReactUI/doc/`
- Spring Boot Install: `etc/install/springBootUI/doc/`

---

**Document End**