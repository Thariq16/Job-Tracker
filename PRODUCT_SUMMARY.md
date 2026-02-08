# Job Tracker - Product Summary

## 1. Summary

**Job Tracker** is a modern **Flutter-based web application** designed to help job seekers manage and optimize their job search process. Built with Firebase as the backend (authentication, Firestore, Storage) and Riverpod for state management, it provides a comprehensive dashboard-driven experience to track applications, improve networking habits, and stay organized throughout the job hunting journey.

**Key Technologies:**
- **Frontend:** Flutter (cross-platform, web-focused)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Riverpod 3.x with NotifierProvider pattern
- **Routing:** GoRouter
- **UI:** Google Fonts, Material Design 3

---

## 2. Features (Currently Implemented)

### 📊 Dashboard & Analytics
- **Overview stats** — Applied today, total applications, response rate
- **Pipeline health** — Visual breakdown of Applied → Interviewing → Offer → Rejected stages
- **Daily goal tracker** — Progress ring showing daily application goals (10/day target)
- **Weekly bar chart** — Last 7 days application activity
- **Activity map** — GitHub-style heatmap showing 12 weeks of application history

### 💼 Job Management
- **Add jobs** via modal with URL parsing (auto-extracts job details from links)
- **Kanban board** for visual pipeline management
- **Job detail view** with full information
- **Status tracking** — Applied, Interviewing, Offer, Rejected

### 👤 Profile & Authentication
- **Google Sign-In** integration
- **Profile management** with CV upload support (to Firebase Storage)
- **Onboarding flow** for new users

### 🔗 LinkedIn Setup Checklist
- Step-by-step guide to optimize LinkedIn profiles
- Progress tracking with completion indicators
- Gamification elements

### 🏢 Target Companies
- Track and manage a list of target companies for networking

### 📈 Daily LinkedIn Engagement
- Track daily networking activities
- Complete daily LinkedIn engagement tasks

### 💌 Referral System
- "Invite a Friend" feature with rewards

### 📝 Feedback System
- **Feature requests** — Submit ideas for new features
- **Bug reports** — Report issues with severity levels

### ⚙️ Settings & Admin
- User preferences and settings
- Admin panel support
- NPS (Net Promoter Score) feedback collection

---

## 3. Upcoming Features (Planned Roadmap)

### 🤖 AI Tools (Planned)

| Feature | Description |
|---------|-------------|
| **CV Reviewer** | AI-powered CV analysis with actionable feedback |
| **CV Writer & Optimizer** | AI-powered CV writing and tailoring for each job |
| **AI Cover Letter** | Generate personalized cover letters instantly |
| **Resume Builder** | AI-powered resume builder with job-specific tailoring |
| **Mock Interviews** | Practice interviews with AI and get instant feedback |
| **ATS Score Integration** | Check how well your resume matches job requirements |

### 🔍 Discovery & Networking (Planned)

| Feature | Description |
|---------|-------------|
| **LinkedIn Integration** | Find hiring managers and connect directly *(In Progress)* |
| **Hiring Manager Finder** | Automatically find and research hiring managers |
| **Related Job Finder** | Discover similar jobs based on your applications |

### 📊 Insights (Planned)

| Feature | Description |
|---------|-------------|
| **Job News Feed** | Industry news and company updates for your targets |
| **Application Analytics** | Track response rates, interview conversion, and trends |
| **Analytics Dashboard** | Visual insights on application patterns and response rates |

### ⚡ Productivity (Planned)

| Feature | Description |
|---------|-------------|
| **Chrome Extension** | One-click job saving from any job board |
| **Interview Scheduler** | Sync with calendar and set reminders |
| **Email Templates** | Follow-up and thank you email templates |
| **Smart Notifications** | Reminders to follow up on applications |

### 🛠️ Technical Backlog
- Headless browser backend for JavaScript-rendered job pages
- Scraping API integration (ScrapingBee/Browserless)
- Manual paste option for job descriptions
- Improved error handling & unit tests

---

*Last updated: February 8, 2026*
