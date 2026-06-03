# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Workspace Type
**Type:** IBM Z Enterprise COBOL Application with Multi-Interface Architecture
**Languages:** IBM Enterprise COBOL for z/OS, JCL, Java 17, JavaScript/React

## Build Commands
- **Full build:** `./build.sh` (builds React frontend, then Maven Java components)
- **Java only:** `mvn clean package` (from project root)
- **React only:** `cd src/bank-application-frontend && yarn install && yarn build`
- **React dev:** `cd src/bank-application-frontend && yarn start`

## Critical Architecture Patterns

### Named Counter Pattern (Non-Obvious)
COBOL programs use ENQ/DEQ with Named Counters for generating sequential account/customer numbers. If DB2 write fails, counter MUST be decremented before DEQUEUE to restore state. See [`CREACC.cbl`](src/base/cobol_src/CREACC.cbl) for reference implementation.

### JVM Server Configuration
Liberty JVM server name is hardcoded as `CBSAWLP` in [`src/Z-OS-Connect-Customer-Services-Interface/pom.xml`](src/Z-OS-Connect-Customer-Services-Interface/pom.xml:191) and [`src/Z-OS-Connect-Payment-Interface/pom.xml`](src/Z-OS-Connect-Payment-Interface/pom.xml:191). Do not change without coordinating CICS configuration.

### Multi-Interface Backend Sharing
Three distinct UIs (BMS 3270, Carbon React, Spring Boot) all invoke the same COBOL backend programs via different paths:
- BMS: Direct CICS program calls
- Carbon React: Liberty → JCICS API → COBOL
- Spring Boot: z/OS Connect → CICS → COBOL

Changes to COBOL programs affect all three interfaces.

## Code Style
- **JavaScript:** Prettier config in [`package.json`](src/bank-application-frontend/package.json:144-149) - single quotes, 80 char width, trailing commas ES5
- **COBOL:** Copybooks in [`src/base/cobol_copy/`](src/base/cobol_copy/) define shared data structures - always use COPY statements rather than duplicating structures
- **Java:** Maven compiler enforces `-Xlint:deprecation` and `-Xlint:unchecked` (see [`src/webui/pom.xml`](src/webui/pom.xml:102-104))

## Data Dictionary
**Location:** bobz/DD.json
The data dictionary contains variable definitions and descriptions for COBOL programs.
Currently includes: CREACC program (15 entries), BNKMENU program (15 entries)

## Technical Documentation

### Architecture & Installation
- [`doc/CBSA_Architecture_guide.md`](doc/CBSA_Architecture_guide.md) - Multi-layer architecture overview
- [`etc/install/base/doc/README.md`](etc/install/base/doc/README.md) - Base COBOL/BMS installation
- [`etc/install/carbonReactUI/doc/CBSA_Carbon_React_UI_installation_deployment_guide.md`](etc/install/carbonReactUI/doc/CBSA_Carbon_React_UI_installation_deployment_guide.md)
- [`etc/install/springBootUI/doc/CBSA_Deploying_the_Payment_Customer_Services_Springboot_apps.md`](etc/install/springBootUI/doc/CBSA_Deploying_the_Payment_Customer_Services_Springboot_apps.md)

### User Guides by Interface
- [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md) - 3270 terminal interface
- [`etc/usage/carbonReactUI/doc/CBSA_Carbon_React_UI_User_Guide.md`](etc/usage/carbonReactUI/doc/CBSA_Carbon_React_UI_User_Guide.md)
- [`etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md`](etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md)
- [`etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md`](etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md)
- [`etc/usage/springBoot/doc/CBSA_Restful_API_guide.md`](etc/usage/springBoot/doc/CBSA_Restful_API_guide.md)

### COBOL Program Documentation Mapping

| Program Category | Programs | Documentation | Purpose |
|-----------------|----------|---------------|---------|
| Menu/Navigation | BNKMENU.cbl | [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md) | Main menu and transaction routing |
| Account Operations | BNK1CAC.cbl, BNK1DAC.cbl, BNK1UAC.cbl, CREACC.cbl, DELACC.cbl, INQACC.cbl, INQACCCU.cbl, UPDACC.cbl | [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md), [`doc/CBSA_Architecture_guide.md`](doc/CBSA_Architecture_guide.md) | Account creation, inquiry, update, deletion |
| Customer Operations | BNK1CCA.cbl, BNK1CCS.cbl, BNK1CRA.cbl, CRECUST.cbl, DELCUS.cbl, INQCUST.cbl, UPDCUST.cbl | [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md), [`etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md`](etc/usage/springBoot/doc/CBSA_Customer_Services_Interface_User_Guide.md) | Customer management and credit agency integration |
| Transaction Processing | BNK1TFN.cbl, DBCRFUN.cbl, XFRFUN.cbl | [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md), [`etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md`](etc/usage/springBoot/doc/CBSA_Payment_Interface_User_Guide.md) | Funds transfer, debit/credit operations |
| Credit Agency | CRDTAGY1.cbl - CRDTAGY5.cbl | [`doc/CBSA_Architecture_guide.md`](doc/CBSA_Architecture_guide.md) | External credit score integration |
| Utilities | ABNDPROC.cbl, BANKDATA.cbl, GETCOMPY.cbl, GETSCODE.cbl | [`doc/CBSA_Architecture_guide.md`](doc/CBSA_Architecture_guide.md) | Abend handling, batch data load, utility functions |
| BMS Maps | BNK1ACC.bms, BNK1CAM.bms, BNK1CCM.bms, BNK1CDM.bms, BNK1DAM.bms, BNK1DCM.bms, BNK1MAI.bms, BNK1TFM.bms, BNK1UAM.bms | [`etc/usage/base/doc/CBSA_BMS_User_Guide.md`](etc/usage/base/doc/CBSA_BMS_User_Guide.md) | 3270 screen definitions |

**Auto-Update Rules:**
1. When modifying COBOL programs, check if changes affect user-facing behavior documented in user guides
2. Account/Customer/Transaction operations may impact multiple interfaces - verify all three UI documentation sets
3. Changes to copybooks (ACCOUNT.cpy, CUSTOMER.cpy) require reviewing all programs that COPY them
4. BMS map changes must be reflected in BMS User Guide screenshots
5. RESTful API changes require updating [`etc/usage/springBoot/doc/CBSA_Restful_API_guide.md`](etc/usage/springBoot/doc/CBSA_Restful_API_guide.md)

## Testing
- **React tests:** `cd src/bank-application-frontend && yarn test`
- **Java tests:** Maven Surefire plugin configured in POMs (no tests currently present)

## Deployment Notes
- CICS region requires CICS TS 6.1+ with APAR PH60795
- Db2 V12+ required for SQL operations
- z/OS Connect server required for RESTful APIs and Spring Boot interfaces
- Installation is sequential: Base COBOL → Carbon React UI → Spring Boot interfaces