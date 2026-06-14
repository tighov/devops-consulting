Title: Book Now
Slug: book
Template: page

<section class="page-hero">
    <div class="container">
        <h1>Book a Consultation</h1>
        <p>Start with a free 30-minute discovery call — or request a specific service directly.</p>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="book-container">

            <div class="book-options">
                <div class="book-option">
                    <div class="book-option-icon">&#128222;</div>
                    <div>
                        <h3>Free Discovery Call (30 min)</h3>
                        <p>No commitment. We'll discuss your infrastructure needs and I'll let you know how I can help. If there's a fit, I'll send a proposal within 48 hours.</p>
                    </div>
                </div>
                <div class="book-option">
                    <div class="book-option-icon">&#128640;</div>
                    <div>
                        <h3>Ready to Start a Project?</h3>
                        <p>Already know what you need? Fill out the form below with details and I'll send you a scoped proposal with fixed pricing.</p>
                    </div>
                </div>
            </div>

            <div class="book-form">
                <h2>Get in Touch</h2>
                <p>Fill out the form and I'll get back to you within 24 hours.</p>

                <div id="form-success" style="display:none; background: rgba(34,197,94,.15); border: 1px solid rgba(34,197,94,.3); border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 20px;">
                    <p style="color: #22c55e; font-weight: 600; margin: 0;">Your request has been sent! I'll get back to you within 24 hours.</p>
                </div>
                <div id="form-error" style="display:none; background: rgba(239,68,68,.15); border: 1px solid rgba(239,68,68,.3); border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 20px;">
                    <p style="color: #ef4444; font-weight: 600; margin: 0;">Something went wrong. Please try again or email me directly.</p>
                </div>

                <form id="contact-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Full Name</label>
                            <input type="text" id="name" name="name" placeholder="John Doe" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" placeholder="john@company.com" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="company">Company Name</label>
                            <input type="text" id="company" name="company" placeholder="Acme Corp">
                        </div>
                        <div class="form-group">
                            <label for="budget">Budget Range</label>
                            <select id="budget" name="budget">
                                <option value="">Select a range</option>
                                <option value="under-500">Under $500</option>
                                <option value="500-1000">$500 – $1,000</option>
                                <option value="1000-2500">$1,000 – $2,500</option>
                                <option value="2500-5000">$2,500 – $5,000</option>
                                <option value="5000+">$5,000+</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="service">Service Interested In</label>
                        <select id="service" name="service" required>
                            <option value="">Select a service</option>
                            <option value="Free Discovery Call">Free Discovery Call</option>
                            <option value="Kubernetes Cluster Audit – $500">Kubernetes Cluster Audit – $500</option>
                            <option value="Docker Containerization – $400">Docker Containerization – $400</option>
                            <option value="Ansible Automation – $600">Ansible Automation – $600</option>
                            <option value="Distributed Tracing Setup – $700">Distributed Tracing Setup – $700</option>
                            <option value="Prometheus + Grafana Monitoring – $800">Prometheus + Grafana Monitoring – $800</option>
                            <option value="GitHub Actions CI/CD – $800">GitHub Actions CI/CD – $800</option>
                            <option value="Centralized Logging (ELK/Loki) – $900">Centralized Logging (ELK/Loki) – $900</option>
                            <option value="GitLab CI/CD Setup – $1,000">GitLab CI/CD Setup – $1,000</option>
                            <option value="Secrets & Vault Management – $1,000">Secrets & Vault Management – $1,000</option>
                            <option value="ArgoCD / GitOps Setup – $1,200">ArgoCD / GitOps Setup – $1,200</option>
                            <option value="Infrastructure Security Hardening – $1,200">Infrastructure Security Hardening – $1,200</option>
                            <option value="Terraform IaC – $1,200+">Terraform IaC – $1,200+</option>
                            <option value="HA PostgreSQL Deployment – $1,500+">HA PostgreSQL Deployment – $1,500+</option>
                            <option value="Disaster Recovery Planning – $1,500">Disaster Recovery Planning – $1,500</option>
                            <option value="Production Kubernetes Setup – $2,500+">Production Kubernetes Setup – $2,500+</option>
                            <option value="Custom Project">Custom Project</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="message">Project Details</label>
                        <textarea id="message" name="message" placeholder="Tell me about your current setup, what problems you're facing, and what you'd like to achieve..." required></textarea>
                    </div>

                    <div class="form-submit">
                        <button type="submit" id="submit-btn" class="btn btn-primary btn-lg">Send Request</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<script>
document.getElementById('contact-form').addEventListener('submit', function(e) {
    e.preventDefault();

    var btn = document.getElementById('submit-btn');
    var successEl = document.getElementById('form-success');
    var errorEl = document.getElementById('form-error');
    btn.textContent = 'Sending...';
    btn.disabled = true;
    successEl.style.display = 'none';
    errorEl.style.display = 'none';

    var data = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        company: document.getElementById('company').value,
        budget: document.getElementById('budget').value,
        service: document.getElementById('service').value,
        subject: document.getElementById('service').value,
        message: document.getElementById('message').value
    };

    fetch(LAMBDA_ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(function(response) {
        if (response.ok) {
            successEl.style.display = 'block';
            document.getElementById('contact-form').reset();
        } else {
            errorEl.style.display = 'block';
        }
    })
    .catch(function() {
        errorEl.style.display = 'block';
    })
    .finally(function() {
        btn.textContent = 'Send Request';
        btn.disabled = false;
    });
});
</script>
