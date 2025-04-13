# 🗄️ Bash-Based Database Engine

A lightweight, interactive database engine built with pure Bash scripting. This project mimics key features of relational databases—like MySQL or PostgreSQL—using the Linux file system, and enhances usability with **Zenity dialogs** and **HTML output for data viewing**.

---

## 📌 Features

- **Database Management**: Create, list, connect to ,and delete databases.
- **Table Operations**: Create, list, and drop tables inside databases.
- **Data Manipulation**: Insert, select, update, and delete records.
- **User Interface**: Zenity-powered GUI dialogs for user-friendly navigation.
- **HTML Output**: Select queries generate HTML files, which open in your browser for easy viewing.
- **Validation & Type Checking**: Ensures correct input types for each column.
- **Modular Scripts**: Each operation has its own script for better readability and maintainability.

---

## 🚀 Getting Started

### Prerequisites

- Linux/macOS with Bash (v4+)
- Zenity (`sudo apt install zenity` on Debian/Ubuntu)
- A modern web browser

### Installation

```bash
git clone https://github.com/Mostafa-Anwar-101/Database-Engine.git
cd Database-Engine
chmod +x *.sh
./main_menu.sh
```
---

## 🖥️ Zenity & HTML Integration
When using the select_from_table.sh script:

- **Data from the selected table is converted into a styled HTML table.**

- **The HTML file is saved temporarily and opened using your default browser.**

- **This makes it much easier to browse table data visually than using terminal output.**

Zenity is used throughout the project to:

- **Show GUI menus**

- **Prompt the user for input**

- **Display alerts and confirmations**
---

## 📂 Project Structure
```pgsql
Database-Engine/
├── databases/                 # Stores user-created databases
│   ├── bashdb/
│   └── test/
│
├── connect_to_database.sh     # Connect to a database
├── create_database.sh         # Create a new database
├── create_table.sh            # Create tables within databases
├── delete_from_table.sh       # Delete specific records
├── drop_database.sh           # Delete databases
├── drop_table.sh              # Drop entire tables
├── insert_into_table.sh       # Insert records into tables
├── list_databases.sh          # Show available databases
├── list_tables.sh             # Show tables in current database
├── main_menu.sh               # Zenity-based main menu
├── select_from_table.sh       # Generate HTML output from select query
├── tables_menu.sh             # Sub-menu for table operations
├── update_table.sh            # Update records in a table
├── utils.sh                   # Helper functions and shared logic
└── README.md                  # This file
```
---

## 🛠️ Usage Overview
Launch the program:

```bash

./main_menu.sh

```
From there, use the Zenity interface to:

**Create or delete databases**

**Create tables and define data types**

**Insert and manage records**

**Perform select queries and view results in your browser**

**All scripts are standalone and can also be run manually if preferred.**
