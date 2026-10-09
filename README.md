# DevOps Dashboard

A containerized Flask web application for managing tasks, with PostgreSQL as the database and a CI pipeline using Jenkins and Docker. The project also includes Prometheus metrics and Grafana dashboards for application monitoring.

## Project Overview

The DevOps Dashboard demonstrates how application development, containerization, continuous integration, and monitoring can work together in a DevOps workflow.

### Application Features

* Task management dashboard.
* Add tasks and mark tasks as completed.
* PostgreSQL database integration.
* Application health endpoint: `/health`
* Database connectivity endpoint: `/db-test`
* Prometheus metrics endpoint: `/metrics`
* Nginx reverse proxy configuration.
* Jenkins pipeline for building and publishing Docker images.
* Prometheus and Grafana for monitoring and visualization.

## Tools and Technologies

| Tool               | Purpose                                 |
| ------------------ | --------------------------------------- |
| Python             | Application programming language        |
| Flask              | Web application framework               |
| PostgreSQL         | Relational database                     |
| Docker             | Containerization                        |
| Docker Hub         | Container image registry                |
| Jenkins            | Continuous integration pipeline         |
| Git                | Version control                         |
| GitHub             | Source code repository                  |
| Nginx              | Reverse proxy                           |
| Prometheus         | Metrics collection and monitoring       |
| Grafana            | Metrics visualization and dashboards    |
| Linux / Amazon EC2 | Cloud server and deployment environment |

## Project Structure

```text
devops-dashboard/
├── app.py
├── requirements.txt
├── Dockerfile
├── Jenkinsfile
├── README.md
├── nginx/
│   └── nginx.conf
├── templates/
│   └── index.html
└── static/
    └── ...
```

> Note: This is the documented core structure. Update it if your actual repository contains additional files or directories, such as Docker Compose configuration or database initialization scripts.

## CI Pipeline

The Jenkins pipeline is designed to:

1. Retrieve the application source code from GitHub.
2. Build the Docker image.
3. Verify the image build.
4. Authenticate to Docker Hub using Jenkins credentials.
5. Push the image to Docker Hub.

**Image repository:** `sriharini242002/devops-dashboard`

The pipeline can be triggered manually in Jenkins or automatically through a configured GitHub webhook.

## Monitoring

### Prometheus

Prometheus collects application metrics from the `/metrics` endpoint. The application exposes request counts and request-duration metrics, including:

* `flask_http_requests_total`
* `flask_http_request_duration_seconds`

### Grafana

Grafana connects to Prometheus as a data source and can be used to create dashboards for monitoring request volume, response duration, and other collected metrics.

## Application Endpoints

| Endpoint              | Purpose                                        |
| --------------------- | ---------------------------------------------- |
| `/`                   | Displays the task dashboard                    |
| `/health`             | Checks application health                      |
| `/db-test`            | Tests PostgreSQL connectivity                  |
| `/metrics`            | Exposes Prometheus metrics                     |
| `/add-task`           | Adds a task using a POST request               |
| `/complete-task/<id>` | Marks a task as completed using a POST request |

## Local Development

### 1. Clone the repository

```bash
git clone https://github.com/sriharini242002/devops-dashboard.git
cd devops-dashboard
```

### 2. Install dependencies

Create and activate a Python virtual environment, then run:

```bash
python -m venv .venv
```

On Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install the application dependencies:

```bash
python -m pip install -r requirements.txt
```

### 3. Configure the database

Set the PostgreSQL connection variables for your environment:

* `DB_HOST`
* `DB_NAME`
* `DB_USER`
* `DB_PASSWORD`
* `DB_PORT`

Ensure PostgreSQL is running and the required database and `tasks` table exist before starting the application.

### 4. Run the application

```bash
python app.py
```

Open `http://127.0.0.1:5000` in your browser.

## Docker Image

The application image is published to Docker Hub:

`docker pull sriharini242002/devops-dashboard:latest`

Configure database connectivity and other required environment variables before running the container. The database must be reachable from the container.

## Future Improvements

* Automate deployments after successful image builds.
* Use environment-based configuration and secure secret management.
* Add application and infrastructure alerts.
* Expand Grafana dashboards and Prometheus alerting.
* Add automated tests to the CI pipeline.

## Author

**Sriharini**

DevOps learning project focused on Flask, Docker, Jenkins, PostgreSQL, Prometheus, Grafana, and AWS cloud deployment.
