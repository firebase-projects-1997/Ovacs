# 👥 Simple Role Permissions Guide

## 🎭 The 5 Roles Explained

Think of these roles like job positions in a law firm:

| Role        | Icon | Think of them as...             | Level       |
| ----------- | ---- | ------------------------------- | ----------- |
| **Owner**   | 👑   | The Boss/Senior Partner         | Highest     |
| **Admin**   | ⚡   | Office Manager/Senior Associate | High        |
| **Diamond** | 💎   | Senior Lawyer                   | Medium-High |
| **Gold**    | 🥇   | Junior Lawyer                   | Medium      |
| **Silver**  | 🥈   | Paralegal/Intern                | Basic       |

---

## 📋 What Each Role Can Do

### 📁 **CASES** (Legal Cases)

| Action                     | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| -------------------------- | -------- | -------- | ---------- | ------- | --------- |
| **Create New Cases**       | ✅ Yes   | ❌ No    | ❌ No      | ❌ No   | ❌ No     |
| **View Cases**             | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Case Details**      | ✅ Yes   | ✅ Yes   | ❌ No      | ❌ No   | ❌ No     |
| **Delete Cases**           | ✅ Yes   | ❌ No    | ❌ No      | ❌ No   | ❌ No     |
| **Assign People to Cases** | ✅ Yes   | ✅ Yes   | ❌ No      | ❌ No   | ❌ No     |

### 👥 **CLIENTS** (Client Information)

| Action               | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| -------------------- | -------- | -------- | ---------- | ------- | --------- |
| **Add New Clients**  | ✅ Yes   | ❌ No    | ❌ No      | ❌ No   | ❌ No     |
| **View Client Info** | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Client Info** | ✅ Yes   | ❌ No    | ❌ No      | ❌ No   | ❌ No     |
| **Delete Clients**   | ✅ Yes   | ❌ No    | ❌ No      | ❌ No   | ❌ No     |

### 📅 **SESSIONS** (Meetings/Appointments)

| Action                    | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| ------------------------- | -------- | -------- | ---------- | ------- | --------- |
| **Schedule New Sessions** | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **View Sessions**         | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Sessions**         | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ❌ No     |
| **Cancel Sessions**       | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |

### 📄 **DOCUMENTS** (Files & Papers)

| Action                   | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| ------------------------ | -------- | -------- | ---------- | ------- | --------- |
| **Upload New Documents** | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **View Documents**       | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Documents**       | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **Delete Documents**     | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |

### 📁 **DOCUMENT GROUPS** (File Folders)

| Action                 | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| ---------------------- | -------- | -------- | ---------- | ------- | --------- |
| **Create New Folders** | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **View Folders**       | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Folders**       | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **Delete Folders**     | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |

### 💬 **MESSAGES** (Chat/Voice Messages)

| Action              | Owner 👑 | Admin ⚡ | Diamond 💎 | Gold 🥇 | Silver 🥈 |
| ------------------- | -------- | -------- | ---------- | ------- | --------- |
| **Send Messages**   | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ❌ No     |
| **Read Messages**   | ✅ Yes   | ✅ Yes   | ✅ Yes     | ✅ Yes  | ✅ Yes    |
| **Edit Messages**   | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |
| **Delete Messages** | ✅ Yes   | ✅ Yes   | ✅ Yes     | ❌ No   | ❌ No     |

---

## 🚦 Document Security Colors

Think of these like security clearance levels:

### 🔴 **RED Documents** (Top Secret)

- **Who can see them:** Only Owner 👑 and Admin ⚡
- **Examples:** Confidential contracts, sensitive legal strategies
- **Think of it as:** "Eyes only for the boss and office manager"

### 🟡 **YELLOW Documents** (Restricted)

- **Who can see them:** Owner 👑, Admin ⚡, and Diamond 💎
- **Examples:** Important case files, client agreements
- **Think of it as:** "Senior staff only"

### 🟢 **GREEN Documents** (General Access)

- **Who can see them:** Everyone (All roles)
- **Examples:** Public records, general correspondence
- **Think of it as:** "Everyone in the office can see these"

---

## 📊 Security Color Access Table

| Document Color | Owner 👑      | Admin ⚡      | Diamond 💎       | Gold 🥇          | Silver 🥈        |
| -------------- | ------------- | ------------- | ---------------- | ---------------- | ---------------- |
| 🔴 **RED**     | ✅ Can Access | ✅ Can Access | ❌ Cannot Access | ❌ Cannot Access | ❌ Cannot Access |
| 🟡 **YELLOW**  | ✅ Can Access | ✅ Can Access | ✅ Can Access    | ❌ Cannot Access | ❌ Cannot Access |
| 🟢 **GREEN**   | ✅ Can Access | ✅ Can Access | ✅ Can Access    | ✅ Can Access    | ✅ Can Access    |

---

## 🎯 Quick Summary

### **Owner 👑** (The Boss)

- **Can do:** Everything! Create, edit, delete anything
- **Document access:** All colors (Red, Yellow, Green)
- **Think:** "I own this place, I can do anything"

### **Admin ⚡** (Office Manager)

- **Can do:** Almost everything except create/delete cases and clients
- **Document access:** All colors (Red, Yellow, Green)
- **Think:** "I manage the office but can't make big business decisions"

### **Diamond 💎** (Senior Lawyer)

- **Can do:** Full access to sessions, documents, and messages. Can only view cases/clients
- **Document access:** Yellow and Green (no Red)
- **Think:** "I handle important work but not the most sensitive stuff"

### **Gold 🥇** (Junior Lawyer)

- **Can do:** Can update sessions and send messages. Everything else is view-only
- **Document access:** Only Green documents
- **Think:** "I can do my daily work but need permission for important stuff"

### **Silver 🥈** (Paralegal/Intern)

- **Can do:** View everything, but cannot create, edit, or delete anything
- **Document access:** Only Green documents
- **Think:** "I can see and learn, but I can't change anything"

---

## 💡 Real-World Examples

**Scenario 1:** A new contract needs to be created

- ✅ **Owner** can create it and mark it as Red (top secret)
- ❌ **Everyone else** needs to ask the Owner to create it

**Scenario 2:** A client meeting needs to be scheduled

- ✅ **Owner, Admin, Diamond** can schedule it
- ❌ **Gold, Silver** need to ask someone with higher access

**Scenario 3:** Someone wants to read a Yellow document

- ✅ **Owner, Admin, Diamond** can read it
- ❌ **Gold, Silver** will get "Access Denied" message

This system ensures that sensitive information stays secure while allowing everyone to do their job effectively!
