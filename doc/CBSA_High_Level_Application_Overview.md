# CICS Banking Sample Application (CBSA)
## High-Level Application Overview

**Document Version:** 1.0  
**Last Updated:** 2026-06-18  
**Purpose:** Executive and technical overview of the CICS Banking Sample Application

---

## Executive Summary

The **CICS Bank Sample Application (CBSA)** is a comprehensive, production-grade banking application that demonstrates modern mainframe application architecture and development practices. It simulates core banking operations from a bank teller's perspective, showcasing the integration of traditional mainframe technologies (COBOL, CICS, DB2, VSAM) with modern interfaces (React, Spring Boot, RESTful APIs).

### Key Highlights

- **Multi-Interface Architecture**: Four distinct user interfaces sharing a common COBOL backend
- **Technology Showcase**: Integrates CICS, COBOL, BMS, DB2, VSAM, Java, Liberty, Spring Boot, React, and z/OS Connect
- **Production Patterns**: Demonstrates enterprise-grade patterns including transaction management, concurrency control, and audit trails
- **Educational Value**: Complete source code provided for learning and teaching purposes
- **Modernization Example**: Illustrates application modernization journey from 3270 terminals to modern web UIs

---

## Application Purpose and Use Cases

### Primary Use Cases

1. **Teaching and Learning Aid**
   - Complete source code demonstrates technology integration
   - Real-world patterns for CICS application development
   - Examples of mainframe-to-modern UI integration

2. **Conversation Starter**
   - Recognizable structure for CICS TS customers
   - Application development lifecycle discussions
   - Modernization strategy conversations

3. **Testing Platform**
   - Out-of-the-box testing for CICS interactions
   - Validation platform for IBM and vendor tools
   - Performance and scalability testing

4. **Modernization Blueprint**
   - Building block for modernization discussions
   - Demonstrates incremental modernization approach
   - Shows coexistence of traditional and modern interfaces

---

## Business Capabilities

CBSA provides comprehensive banking functionality including:

### Customer Management
- Create new customers with credit score integration
- Update customer information (address, contact details)
- Inquire customer details and credit scores
- Delete customers (with validation checks)
- Automatic credit score refresh based on review cycles

### Account Management
- Open new accounts (Savings, Current, Mortgage, Loan, ISA)
- Update account details (interest rates, overdraft limits)
- Inquire account information and balances
- Delete accounts (with balance verification)
- Support for multiple accounts per customer (up to 10)

### Transaction Processing
- Deposit funds (credit operations)
- Withdraw funds (debit operations)
- Transfer funds between accounts
- Real-time balance updates
- Complete audit trail of all transactions

### Reporting and Inquiry
- Account balance inquiries
- Transaction history
- Customer account listings
- Credit score tracking

---

## Architecture Overview

### Multi-Tier Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
├──────────────┬──────────────┬──────────────┬────────────────────┤
│  BMS 3270    │ Carbon React │ Customer     │  Payment           │
│  Terminal    │  Web UI      │ Services UI  │  Interface UI      │
│  (Traditional)│ (Modern Web) │ (Spring Boot)│  (Spring Boot)    │
└──────┬───────┴──────┬───────┴──────┬───────┴────────┬───────────┘
       │              │              │                │
       │              │              └────────┬───────┘
       │              │                       │
       v              v                       v
┌─────────────────────────────────────────────────────────────────┐
│                   INTEGRATION LAYER                              │
├──────────────┬──────────────────────────┬────────────────────────┤
│ Direct CICS  │  Liberty JVM Server      │  z/OS Connect EE       │
│ Calls        │  (JCICS API)             │  (RESTful Services)    │
└──────┬───────┴──────┬───────────────────┴────────┬───────────────┘
       │              │                            │
       └──────────────┴────────────┬───────────────┘
                                   v
┌─────────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│              CICS Transaction Server (z/OS)                      │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  COBOL Business Programs (29 programs)                    │  │
│  │  • Account Operations (CREACC, DELACC, INQACC, UPDACC)   │  │
│  │  • Customer Operations (CRECUST, DELCUS, INQCUST, UPDCUST)│ │
│  │  • Transaction Processing (DBCRFUN, XFRFUN)               │  │
│  │  • Credit Agency Integration (CRDTAGY1-5)                 │  │
│  │  • Utilities (ABNDPROC, GETCOMPY, GETSCODE)               │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────┘
                                 v
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                  │
├──────────────────────────┬──────────────────────────────────────┤
│  DB2 Database            │  VSAM Files                          │
│  • ACCOUNT table         │  • CUSTOMER file                     │
│  • PROCTRAN table        │  • ABNDFILE                          │
│  • CONTROL table         │                                      │
└──────────────────────────┴──────────────────────────────────────┘
```

### Key Architectural Principles

1. **Shared Backend Logic**: All four UIs invoke the same COBOL programs, ensuring consistency
2. **Separation of Concerns**: Clear separation between presentation, integration, business logic, and data layers
3. **Technology Coexistence**: Traditional and modern technologies work together seamlessly
4. **Incremental Modernization**: New interfaces added without disrupting existing functionality

---

## User Interfaces

### 1. BMS 3270 Terminal Interface (Base)
**Technology**: COBOL + BMS Maps  
**Target Users**: Traditional bank tellers  
**Access Method**: Direct CICS program calls  
**Status**: Core interface, installed first

**Features**:
- Classic green-screen interface
- Full banking functionality
- Keyboard-driven navigation
- Optimized for high-speed data entry

### 2. Carbon React Web UI
**Technology**: React 18 + Carbon Design System + Liberty JVM  
**Target Users**: Modern web users  
**Access Method**: Liberty JVM → JCICS API → COBOL  
**Status**: Optional, requires Liberty JVM server

**Features**:
- Modern, responsive web interface
- IBM Carbon Design System components
- RESTful API integration
- Browser-based access

### 3. Customer Services Interface
**Technology**: Spring Boot 3.5 + z/OS Connect  
**Target Users**: Customer service representatives  
**Access Method**: Spring Boot → z/OS Connect → CICS → COBOL  
**Status**: Optional, requires z/OS Connect server

**Features**:
- Customer-focused operations
- Credit score management
- Account inquiry and updates
- RESTful API backend

### 4. Payment Interface
**Technology**: Spring Boot 3.5 + z/OS Connect  
**Target Users**: Payment processing staff  
**Access Method**: Spring Boot → z/OS Connect → CICS → COBOL  
**Status**: Optional, requires z/OS Connect server

**Features**:
- Payment processing
- Fund transfers
- Debit/credit operations
- Transaction history

### 5. RESTful API
**Technology**: z/OS Connect EE  
**Target Users**: External systems and developers  
**Access Method**: HTTP/HTTPS → z/OS Connect → CICS → COBOL  
**Status**: Available with z/OS Connect installation

**Features**:
- Standard REST endpoints
- JSON request/response
- Programmatic access to all banking functions
- Integration with external systems

---

## Technology Stack

### Mainframe Technologies
| Technology | Version | Purpose |
|------------|---------|---------|
| **CICS TS** | 6.1+ (with APAR PH60795) | Transaction processing platform |
| **IBM Enterprise COBOL** | z/OS | Business logic implementation |
| **DB2** | V12+ | Relational database for accounts and transactions |
| **VSAM** | z/OS | Customer data storage |
| **BMS** | CICS | 3270 screen definitions |
| **JCL** | z/OS | Batch processing and installation |

### Modern Technologies
| Technology | Version | Purpose |
|------------|---------|---------|
| **Java** | 17 | Liberty and Spring Boot applications |
| **Liberty** | Latest | JVM server in CICS for Carbon React UI |
| **Spring Boot** | 3.5 | Customer Services and Payment interfaces |
| **React** | 18 | Modern web UI framework |
| **Carbon Design** | Latest | IBM design system for React UI |
| **z/OS Connect EE** | Latest | RESTful API gateway |
| **Maven** | 3.x | Java build automation |
| **Yarn** | Latest | React build and dependency management |

---

## Data Architecture

### DB2 Tables

#### ACCOUNT Table
**Purpose**: Store all account information  
**Key**: SORTCODE + ACCOUNT_NUMBER (8 digits)  
**Records**: One per bank account  
**Key Fields**:
- Customer number (links to CUSTOMER file)
- Account type (SAVING, CURRENT, MORTGAGE, LOAN, ISA)
- Interest rate
- Overdraft limit
- Available and actual balances
- Statement dates

#### PROCTRAN Table
**Purpose**: Complete audit trail of all transactions  
**Key**: SORTCODE + ACCOUNT_NUMBER + TIMESTAMP  
**Records**: One per transaction (debit, credit, or transfer)  
**Key Fields**:
- Transaction type (TFR, DR, CR)
- Amount
- Timestamp (date and time)
- Reference number
- Description

#### CONTROL Table
**Purpose**: Application control data and counters  
**Key**: CONTROL_NAME  
**Records**: Configuration and counter values  
**Key Data**:
- Company name
- Sort code
- Customer number counter (per sort code)
- Account number counter (per sort code)

### VSAM Files

#### CUSTOMER File
**Purpose**: Store customer information  
**Key**: SORTCODE + CUSTOMER_NUMBER (10 digits)  
**Records**: One per customer  
**Key Fields**:
- Name (60 characters)
- Address (160 characters)
- Date of birth
- Credit score (3 digits)
- Credit score review date

#### ABNDFILE
**Purpose**: Error logging and debugging  
**Key**: TASKNO + TIMESTAMP  
**Records**: One per abend/error  
**Key Fields**:
- Task number
- Abend code
- Program name
- SQLCODE (if DB2 error)
- Error message

---

## Critical Design Patterns

### 1. Named Counter Pattern (Concurrency Control)

**Purpose**: Generate unique sequential numbers for customers and accounts  
**Challenge**: Multiple concurrent transactions must not generate duplicate numbers  
**Solution**: ENQ/DEQ resource locking with rollback capability

**Implementation**:
```
1. ENQ on named resource (e.g., "CBSACUST" + sort code)
2. Read current counter from CONTROL table
3. Increment counter in memory
4. Perform business operation (write to DB2/VSAM)
5. If operation succeeds:
   - Update CONTROL table with new counter
6. If operation fails:
   - Decrement counter (rollback)
7. DEQ resource (release lock)
```

**Critical Rule**: Counter MUST be decremented before DEQ if the business operation fails. This ensures the counter remains synchronized with actual records.

**Reference Implementation**: [`CREACC.cbl`](../src/base/cobol_src/CREACC.cbl)

### 2. Multi-Interface Backend Sharing

**Pattern**: Single COBOL backend serves multiple UI technologies  
**Benefit**: Consistency, reduced maintenance, single source of truth

**Implementation**:
- BMS interface: Direct CICS LINK to COBOL programs
- Carbon React: Liberty JVM → JCICS Channel/Container API → COBOL
- Spring Boot: HTTP → z/OS Connect → CICS → COBOL

**Key Insight**: Changes to COBOL business logic automatically propagate to all interfaces

### 3. COMMAREA Communication

**Purpose**: Pass data between COBOL programs  
**Pattern**: Structured data exchange via communication area

**Implementation**:
- Caller populates COMMAREA structure (defined in copybook)
- EXEC CICS LINK PROGRAM with COMMAREA
- Called program processes and updates COMMAREA
- Caller reads results from COMMAREA

**Copybooks**: Each program pair has a dedicated COMMAREA copybook (e.g., CREACC.cpy, INQACC.cpy)

### 4. Credit Score Integration

**Purpose**: Simulate external credit agency integration  
**Pattern**: Random selection of credit agency stubs

**Implementation**:
- Five credit agency programs (CRDTAGY1-5)
- Each returns different score range (100-199, 200-299, etc.)
- Random selection when creating/updating customers
- Periodic refresh based on review date
- Score stored in CUSTOMER record

---

## Component Inventory

### COBOL Programs (29 total)

| Category | Count | Programs |
|----------|-------|----------|
| **Menu/Navigation** | 1 | BNKMENU |
| **Account Operations** | 8 | CREACC, DELACC, INQACC, INQACCCU, UPDACC, BNK1CAC, BNK1DAC, BNK1UAC |
| **Customer Operations** | 8 | CRECUST, DELCUS, INQCUST, UPDCUST, BNK1CCA, BNK1CCS, BNK1CRA, BNK1DCS |
| **Transaction Processing** | 3 | DBCRFUN, XFRFUN, BNK1TFN |
| **Credit Agency** | 5 | CRDTAGY1, CRDTAGY2, CRDTAGY3, CRDTAGY4, CRDTAGY5 |
| **Utilities** | 4 | ABNDPROC, BANKDATA, GETCOMPY, GETSCODE |

### Supporting Components

| Component Type | Count | Purpose |
|----------------|-------|---------|
| **COBOL Copybooks** | 36 | Data structures and communication areas |
| **BMS Maps** | 9 | 3270 screen definitions |
| **Java Classes (Liberty)** | 25+ | Carbon React UI backend |
| **Spring Boot Projects** | 2 | Customer Services and Payment interfaces |
| **React Components** | Multiple | Modern web UI |
| **z/OS Connect Services** | 4 | RESTful API definitions |

---

## Key Business Flows

### Create Customer Flow
```
User Input → UI Layer → CRECUST.cbl
    ↓
1. ENQ Named Counter (CBSACUST + SortCode)
2. Get Next Customer Number from CONTROL table
3. Link to CRDTAGY* for Credit Score
4. Write CUSTOMER record to VSAM
5. Update CONTROL table with new counter
6. DEQ Named Counter
    ↓
Return 10-digit Customer Number
```

**Validation**: Customer name, address, date of birth  
**Output**: Unique 10-digit customer number  
**Audit**: Credit score stored with review date

### Create Account Flow
```
User Input → UI Layer → CREACC.cbl
    ↓
1. Validate Customer Exists (INQCUST)
2. Check Account Count < 10 (INQACCCU)
3. Validate Account Type
4. ENQ Named Counter (CBSAACCT + SortCode)
5. Get Next Account Number from CONTROL table
6. INSERT into ACCOUNT table (DB2)
7. INSERT into PROCTRAN table (DB2)
8. Update CONTROL table
9. DEQ Named Counter
    ↓
Return 8-digit Account Number
```

**Validation**: Customer exists, max 10 accounts, valid account type  
**Output**: Unique 8-digit account number  
**Audit**: Transaction recorded in PROCTRAN

### Transfer Funds Flow
```
User Input → UI Layer → XFRFUN.cbl
    ↓
1. Validate Source Account (INQACC)
2. Validate Target Account (INQACC)
3. Check Sufficient Funds
4. Debit Source Account (DBCRFUN)
5. Credit Target Account (DBCRFUN)
6. INSERT 2 records into PROCTRAN (DB2)
    ↓
Return Success/Failure
```

**Validation**: Both accounts exist, sufficient funds  
**Transaction**: Atomic debit/credit operation  
**Audit**: Two PROCTRAN records (debit + credit)

---

## System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **CICS TS** | Version 6.1 with APAR PH60795 or later |
| **DB2** | Version 12 or later |
| **z/OS** | Compatible with CICS TS 6.1+ |
| **Java** | Version 17 (for Liberty and Spring Boot) |
| **Node.js/Yarn** | Latest stable (for React build) |

### Optional Components

| Component | Required For |
|-----------|--------------|
| **Liberty JVM Server** | Carbon React UI |
| **z/OS Connect EE** | RESTful API, Customer Services UI, Payment UI |
| **Maven** | Java component builds (wrapper included) |

### Storage Requirements

| Resource | Requirement |
|----------|-------------|
| **DB2 Tables** | 3 tables (ACCOUNT, PROCTRAN, CONTROL) |
| **VSAM Files** | 2 files (CUSTOMER, ABNDFILE) |
| **CICS Resources** | Programs, transactions, file definitions |
| **Liberty** | JVM server configuration and WAR files |

---

## Installation Overview

### Sequential Installation Process

CBSA installation follows a three-phase approach:

#### Phase 1: Base COBOL/BMS Installation (Mandatory)
**Components**:
- COBOL programs (29 programs)
- BMS maps (9 maps)
- DB2 tables (ACCOUNT, PROCTRAN, CONTROL)
- VSAM files (CUSTOMER, ABNDFILE)
- CICS resource definitions

**Documentation**: [`etc/install/base/doc/README.md`](../etc/install/base/doc/README.md)

**Result**: Fully functional 3270 terminal interface

#### Phase 2: Carbon React UI Installation (Optional)
**Prerequisites**: Phase 1 completed  
**Components**:
- Liberty JVM server configuration
- React frontend build
- Java backend (Liberty WAR)
- JCICS API integration

**Documentation**: [`etc/install/carbonReactUI/doc/CBSA_Carbon_React_UI_installation_deployment_guide.md`](../etc/install/carbonReactUI/doc/CBSA_Carbon_React_UI_installation_deployment_guide.md)

**Result**: Modern web interface available

#### Phase 3: Spring Boot UIs Installation (Optional)
**Prerequisites**: Phase 1 completed, z/OS Connect configured  
**Components**:
- Customer Services Spring Boot application
- Payment Interface Spring Boot application
- z/OS Connect service definitions
- RESTful API endpoints

**Documentation**: [`etc/install/springBootUI/doc/CBSA_Deploying_the_Payment_Customer_Services_Springboot_apps.md`](../etc/install/springBootUI/doc/CBSA_Deploying_the_Payment_Customer_Services_Springboot_apps.md)

**Result**: Customer Services and Payment interfaces available, RESTful API enabled

### Build Commands

```bash
# Full build (React + Java)
./build.sh

# Java components only
mvn clean package

# React frontend only
cd src/bank-application-frontend
yarn install
yarn build

# React development server
cd src/bank-application-frontend
yarn start
```

---

## Security Considerations

### Authentication and Authorization
- CICS security integration for all interfaces
- User authentication required for all operations
- Transaction-level security controls
- Resource-level access control

### Data Protection
- DB2 table-level security
- VSAM file access controls
- Encrypted communication for web interfaces (HTTPS)
- Audit trail of all transactions in PROCTRAN table

### Error Handling
- Comprehensive abend handling (ABNDPROC)
- Error logging to ABNDFILE
- Graceful error messages to users
- Transaction rollback on failures

---

## Performance and Scalability

### Concurrency Control
- ENQ/DEQ for critical sections (counter generation)
- DB2 transaction management
- CICS task isolation
- Optimistic locking where appropriate

### Scalability Features
- Stateless COBOL programs (can run in any CICS region)
- DB2 connection pooling
- Liberty JVM server thread management
- Horizontal scaling via multiple CICS regions

### Performance Optimizations
- Indexed DB2 tables for fast lookups
- VSAM keyed access for customer data
- Efficient COMMAREA communication
- Minimal data transfer between layers

---

## Monitoring and Operations

### Operational Monitoring
- CICS transaction monitoring
- DB2 performance monitoring
- Liberty JVM metrics
- Application-level logging

### Audit and Compliance
- Complete transaction history in PROCTRAN table
- Timestamp on all transactions
- User identification in CICS context
- Error logging in ABNDFILE

### Maintenance
- Modular program structure for easy updates
- Copybook-based data structures for consistency
- Comprehensive documentation
- Test data generation utilities (BANKDATA)

---

## Documentation Resources

### Architecture and Design
- [Architecture Guide](CBSA_Architecture_guide.md) - Detailed architecture documentation
- [Application Inventory](CBSA_Application_Inventory.md) - Complete component inventory
- [COBOL Coding Standards](CBSA_COBOL_Coding_Standards.md) - Development standards

### Installation Guides
- [Base Installation](../etc/install/base/doc/README.md) - COBOL/BMS installation
- [Carbon React UI Installation](../etc/install/carbonReactUI/doc/CBSA_Carbon_React_UI_installation_deployment_guide.md)
- [Spring Boot Installation](../etc/install/springBootUI/doc/CBSA_Deploying_the_Payment_Customer_Services_Springboot_apps.md)

### User Guides
- [BMS User Guide](../etc/usage/base/doc/CBSA_BMS_User_Guide.md) - 3270 terminal interface
- [Carbon React UI User Guide](../etc/usage/carbonReactUI/doc/CBSA_Carbon_React_UI_User_Guide.md)
- [Customer Services User Guide](../etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md)
- [Payment Interface User Guide](../etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md)
- [RESTful API Guide](../etc/usage/springBoot/doc/CBSA_Restful_API_guide.md)

---

## Conclusion

The CICS Banking Sample Application represents a comprehensive example of modern mainframe application development. It successfully demonstrates:

1. **Technology Integration**: Seamless integration of traditional mainframe and modern technologies
2. **Architectural Patterns**: Production-grade patterns for transaction processing, concurrency control, and data management
3. **Modernization Path**: Clear progression from traditional 3270 interfaces to modern web UIs
4. **Educational Value**: Complete, well-documented source code for learning and teaching
5. **Practical Application**: Real-world banking operations with proper error handling and audit trails

CBSA serves as both a learning tool and a conversation starter for organizations considering mainframe application modernization, demonstrating that traditional and modern technologies can coexist and complement each other effectively.

---

## Appendix: Quick Reference

### Key File Locations
```
src/base/cobol_src/          # COBOL programs (29 files)
src/base/cobol_copy/         # COBOL copybooks (36 files)
src/base/bms_src/            # BMS maps (9 files)
src/webui/                   # Liberty JVM application
src/bank-application-frontend/ # React UI
src/Z-OS-Connect-Customer-Services-Interface/ # Customer Services Spring Boot
src/Z-OS-Connect-Payment-Interface/          # Payment Spring Boot
src/zosconnect_artefacts/    # z/OS Connect service definitions
```

### Key Programs by Function
```
Customer:  CRECUST, DELCUS, INQCUST, UPDCUST
Account:   CREACC, DELACC, INQACC, UPDACC
Transfer:  XFRFUN, DBCRFUN
Menu:      BNKMENU
Utility:   ABNDPROC, GETCOMPY, GETSCODE
```

### Data Stores
```
DB2:   ACCOUNT, PROCTRAN, CONTROL
VSAM:  CUSTOMER, ABNDFILE
```

### Contact and Support
- GitHub Repository: https://github.com/cicsdev/cics-banking-sample-application-cbsa
- License: Eclipse Public License v2.0
- Contributors: See MAINTAINERS.md

---

**Document End**