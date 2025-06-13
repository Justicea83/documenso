# Creating your own signing certificate

For the digital signature of your documents you need a signing certificate in .p12 format (public and private key). You can buy one (not recommended for dev) or use the steps to create a self-signed one:

1. Generate a private key using the OpenSSL command. You can run the following command to generate a 2048-bit RSA key:

   `openssl genrsa -out private.key 2048`

2. Generate a self-signed certificate using the private key. You can run the following command to generate a self-signed certificate:

   `openssl req -new -x509 -key private.key -out certificate.crt -days 365`

   This will prompt you to enter some information, such as the Common Name (CN) for the certificate. Make sure you enter the correct information. The -days parameter sets the number of days for which the certificate is valid.

3. Combine the private key and the self-signed certificate to create the p12 certificate. You can run the following command to do this:

   `openssl pkcs12 -export -out certificate.p12 -inkey private.key -in certificate.crt`

4. You will be prompted to enter a password for the p12 file. Choose a strong password and remember it, as you will need it to use the certificate (**can be empty for dev certificates**)

5. Place the certificate `/apps/web/resources/certificate.p12` (If the path does not exist, it needs to be created)

## Docker

> We are still working on the publishing of docker images, in the meantime you can follow the steps below to create a production ready docker image.

Want to create a production ready docker image? Follow these steps:

- cd into `docker` directory
- Make `build.sh` executable by running `chmod +x build.sh`
- Run `./build.sh` to start building the docker image.
- Publish the image to your docker registry of choice (or) If you prefer running the image from local, run the below command

```
docker run -d --restart=unless-stopped -p 3000:3000 -v documenso:/app/data --name documenso documenso:latest
```

Command Breakdown:

- `-d` - Let's you run the container in background
- `-p` - Passes down which ports to use. First half is the host port, Second half is the app port. You can change the first half anything you want and reverse proxy to that port.
- `-v` - Volume let's you persist the data
- `--name` - Name of the container
- `documenso:latest` - Image you have built

## Deployment

We support a variety of deployment methods, and are actively working on adding more. Stay tuned for updates!

## Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/DjrRRX)

## Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/documenso/documenso)

# Django Document Signing System Implementation Plan

## Context: Learning from Documenso

**Documenso** is an open-source DocuSign alternative built with modern web technologies. Key insights from their implementation:

### Architecture Overview

- **Tech Stack**: TypeScript, React Router (Remix), Prisma ORM, PostgreSQL, tRPC, Tailwind CSS
- **PDF Handling**: React-PDF for viewing, PDF-Lib for manipulation, custom @documenso/pdf-sign package
- **Multi-tenant**: Organization/team structure with role-based permissions
- **Security**: Token-based recipient authentication, audit logging, HTTPS-only communications
- **Signing Methods**: Local certificates and Google Cloud HSM support

### Core Workflow Pattern

1. **Document Upload** → PDF validation and storage
2. **Recipient Setup** → Email addresses with signing order
3. **Field Placement** → Drag-drop signature/form fields on PDF pages
4. **Send for Signing** → Email notifications with secure token links
5. **Signing Process** → Mobile-friendly interface with signature pad
6. **Completion** → Final PDF generation with audit trail

### Key Database Entities

- `Users` - Account management with roles and organizations
- `Documents` - Core signing documents with status tracking
- `Recipients` - People who need to sign with token-based auth
- `Fields` - Signature/form fields positioned on document pages
- `Organizations/Teams` - Multi-tenant structure
- `Templates` - Reusable document patterns
- `Webhooks` - Integration points for external systems

---

## Implementation Plan: Django Document Signing System for Recruiters

### Phase 1: Core Architecture & Models

**Database Design**

- Document model with status flow (Draft → Pending → Completed/Cancelled)
- Recipient model with token-based authentication (no account signup required)
- SignatureField model for positioning form elements on PDF pages
- AuditLog model for compliance and tracking
- User model extension for recruiter accounts

**Security Strategy**

- UUID-based tokens for recipient access
- Time-limited signing URLs with expiration
- HTTPS-only communications
- Input validation and file type restrictions
- Basic audit trail for legal compliance

### Phase 2: Backend Dependencies (Python/Django)

```python
# requirements.txt
Django>=4.2
djangorestframework
django-cors-headers
Pillow>=10.0.0
PyPDF2>=3.0.0          # PDF reading and manipulation
reportlab>=4.0.0       # PDF generation and overlays
cryptography>=41.0.0   # Digital signature capabilities
django-mail-templated  # Email template management
python-decouple        # Environment variable management
celery>=5.3.0          # Background task processing
redis>=4.0.0           # Celery broker and caching
django-storages        # Cloud storage integration (S3/GCS)
boto3                  # AWS SDK for S3 integration
whitenoise             # Static file serving
psycopg2-binary        # PostgreSQL adapter
```

### Phase 3: Frontend Dependencies (JavaScript)

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",

    // PDF Handling
    "react-pdf": "^7.5.0", // PDF viewing component
    "pdf-lib": "^1.17.1", // PDF manipulation
    "pdfjs-dist": "^3.11.0", // PDF.js for rendering

    // Signature Capture
    "react-signature-canvas": "^1.0.6", // Signature pad component
    "signature_pad": "^4.1.7", // Base signature pad library

    // Drag & Drop for Field Placement
    "react-draggable": "^4.4.5", // Draggable components
    "react-resizable": "^3.0.5", // Resizable field components

    // UI Components
    "tailwindcss": "^3.3.0", // CSS framework
    "@headlessui/react": "^1.7.0", // Accessible UI components
    "@heroicons/react": "^2.0.0", // Icon library

    // Form Handling
    "react-hook-form": "^7.43.0", // Form management
    "zod": "^3.20.0", // Schema validation
    "@hookform/resolvers": "^3.0.0", // Form validation integration

    // HTTP Client
    "axios": "^1.3.0", // API requests
    "react-query": "^3.39.0", // Server state management

    // Utilities
    "clsx": "^1.2.0", // Conditional classNames
    "date-fns": "^2.29.0", // Date manipulation
    "uuid": "^9.0.0", // UUID generation

    // File Upload
    "react-dropzone": "^14.2.0", // File drag-drop upload

    // Notifications
    "react-hot-toast": "^2.4.0" // Toast notifications
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.0",
    "typescript": "^5.0.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  }
}
```

### Phase 4: Core Features (MVP)

**1. Document Management**

- PDF upload with validation (size, type, page count)
- Document metadata (title, description, status)
- Template creation for reusable contracts/offers
- Document preview with page navigation

**2. Recipient Management**

- Add candidate emails with signing order
- Bulk recipient import from CSV
- Sequential vs parallel signing workflows
- Reminder email scheduling

**3. Field Placement System**

- Drag-drop interface for field positioning
- Field types: Signature, Text, Date, Checkbox
- Field validation (required/optional)
- Template field patterns for quick setup

**4. Signing Interface**

- Token-based access (no account required)
- Mobile-responsive signing experience
- HTML5 signature pad with touch support
- Form field completion with validation
- Progress indicator for multi-page documents

**5. Email Notifications**

- Customizable email templates
- Signing invitation emails
- Reminder notifications
- Completion confirmations
- Branded email layouts

### Phase 5: PDF Processing Service

**Core Capabilities**

- PDF page count and metadata extraction
- Field overlay positioning system
- Signature image embedding
- Final document generation with signatures
- Document watermarking (optional)

**Implementation Strategy**

- Background task processing with Celery
- Temporary file management and cleanup
- Error handling for corrupted PDFs
- Performance optimization for large documents

### Phase 6: Frontend Architecture

**Component Structure**

```
src/
├── components/
│   ├── DocumentViewer/        # PDF display component
│   ├── FieldEditor/          # Field placement interface
│   ├── SignaturePad/         # Signature capture
│   ├── RecipientManager/     # Recipient setup
│   └── Dashboard/            # Main recruiter interface
├── pages/
│   ├── DocumentCreate/       # Upload and setup
│   ├── DocumentEdit/         # Field placement
│   ├── SigningPage/          # Candidate signing
│   └── Dashboard/            # Document management
├── hooks/                    # Custom React hooks
├── services/                 # API integration
└── utils/                    # Helper functions
```

**State Management**

- React Query for server state
- Context API for global app state
- Local state for form handling
- URL state for deep linking

### Phase 7: Security & Compliance

**Authentication & Authorization**

- JWT tokens for recruiter sessions
- UUID-based recipient tokens
- Role-based access control
- Session timeout handling

**Data Protection**

- HTTPS enforcement
- File encryption at rest
- Secure token generation
- Input sanitization
- CORS configuration

**Audit & Compliance**

- Document access logging
- Signature timestamp verification
- IP address tracking
- User action audit trail
- GDPR-compliant data handling

### Phase 8: Integration Points

**Email Service Integration**

- SendGrid or AWS SES setup
- Template management system
- Delivery status tracking
- Bounce handling

**Storage Integration**

- AWS S3 or Google Cloud Storage
- CDN for fast document delivery
- Backup and retention policies
- Access control and presigned URLs

**HR System Integration**

- Webhook endpoints for status updates
- REST API for external systems
- Bulk document operations
- Reporting and analytics endpoints

### Phase 9: Deployment Strategy

**Environment Setup**

- Development: Local with Docker Compose
- Staging: Cloud deployment for testing
- Production: Scalable cloud infrastructure

**Infrastructure Requirements**

- PostgreSQL database with replication
- Redis for caching and task queues
- Background worker processes
- Load balancer for high availability
- SSL certificate management

**Monitoring & Maintenance**

- Application performance monitoring
- Error tracking and alerting
- Database backup automation
- Security update procedures
- Usage analytics and reporting

### Phase 10: Testing Strategy

**Backend Testing**

- Unit tests for business logic
- Integration tests for API endpoints
- Database migration testing
- PDF processing validation

**Frontend Testing**

- Component unit tests
- Integration tests for user flows
- Cross-browser compatibility
- Mobile responsiveness testing
- Accessibility compliance

---

## Key Technical Decisions

### 1. Digital Signature vs Image Overlay

**Recommendation**: Start with image overlay for MVP, add certificate-based signing later

- **Image Overlay**: Simpler implementation, faster development
- **Digital Signatures**: Legal compliance, higher security (Phase 2)

### 2. Authentication Strategy

**Recommendation**: Recruiter accounts + token-based recipient access

- Recruiters need full accounts for document management
- Recipients use secure tokens (no signup friction)
- Support guest signing with email verification

### 3. PDF Processing Approach

**Recommendation**: Server-side processing with client-side preview

- Use PyPDF2/ReportLab for server-side manipulation
- React-PDF for client-side viewing and field placement
- Background processing for large documents

### 4. Mobile Strategy

**Recommendation**: Progressive Web App (PWA)

- Mobile-responsive design with touch-optimized signing
- Offline capability for completed documents
- Native app consideration for Phase 2

### 5. Multi-tenancy

**Recommendation**: Single-tenant MVP with multi-tenant architecture

- Design for multiple organizations from the start
- Implement single organization initially
- Easy migration path for enterprise features

---

## Success Metrics

### MVP Success Criteria

- Upload and send document for signing: < 5 minutes
- Mobile signing completion rate: > 85%
- Document processing time: < 30 seconds
- System uptime: > 99.5%
- User onboarding: < 2 minutes for recruiters

### Performance Targets

- Page load time: < 2 seconds
- PDF processing: < 10 seconds for 20-page documents
- API response time: < 500ms
- Concurrent users: 100+ without degradation
- Storage efficiency: Optimized PDF compression

This implementation plan provides a solid foundation for building a production-ready document signing system tailored for recruitment workflows while learning from Documenso's proven architecture and design patterns.
