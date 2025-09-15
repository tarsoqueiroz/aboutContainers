# Keycloak: SSO Course from Zero to Hero

## About

> [`https://www.udemy.com/course/keycloak-sso-course-from-zero-to-hero`](https://www.udemy.com/course/keycloak-sso-course-from-zero-to-hero)

SSO with Keycloak, IAM, Keycloak API, Integration with Spring Boot, Angular, Fast API, React and Event Listeners.

In this course, you will learn Keycloak, an open-source software product that allows single sign-on with Identity and Access Management aimed at modern applications.

**Keycloak** is an open-source tool that provides identity and access management for web applications and services. It supports standard protocols such as OpenID Connect, OAuth 2.0, and SAML 2.0, and offers features such as single sign-on, user federation, social login, and authorization policies.

## Introduction

### Why learn Keycloak?

- User registration and login
- Developer can focus on core technology
- Uses best practices
- Centralized user Management
- SSO, Social Identity Providers, and Federation

Keycloak is a powerful open-source identity and access management (IAM) solution that provides Single Sign-On (SSO), user authentication, and authorization capabilities. Let’s break down why normal users might want to learn about Keycloak:

**Single Sign-On (SSO)**:

- **Convenience:** With SSO, users can log in once and access multiple applications without needing to remember separate credentials for each service. It streamlines the login process.
- **Time-Saving:** Imagine not having to enter your username and password every time you switch between different tools or services. SSO makes that possible.

**Security and Centralized Authentication**:

- **Enhanced Security:** Keycloak ensures secure authentication by supporting various authentication mechanisms (e.g., username/password, social logins, multi-factor authentication).
- **Centralized User Management:** Organizations can manage user accounts, roles, and permissions centrally in Keycloak. This simplifies administration and reduces the risk of security breaches.

**Authorization and Fine-Grained Access Control**:

- **Role-Based Access Control (RBAC):** Keycloak allows for the definition of roles and their association with users. Users can be granted specific permissions based on their roles.
- **Scopes and Claims:** Keycloak supports OAuth 2.0 and OpenID Connect, enabling fine-grained control over what data an application can access.

**Social Logins and Federation**:

- **Social Identity Providers:** Keycloak integrates with popular social platforms (like Google, Facebook, and GitHub) for seamless login experiences.
- **Federation:** Organizations can connect Keycloak to external identity providers (e.g., Active Directory, LDAP) to federate user identities.

**Customizable User Interfaces**:

- **Branding:** Keycloak allows customization of login pages, themes, and email templates. Organizations can maintain a consistent brand experience.
- **User Self-Service:** Users can reset passwords, manage their profiles, and view their sessions—all through Keycloak’s user-friendly interfaces.

**Open Source and Community Support**:

- **Cost-Effective:** Keycloak is free and open source, making it an attractive option for organizations looking to implement IAM without hefty licensing fees.
- **Active Community:** The Keycloak community actively contributes to its development, provides support, and shares best practices.

Remember, even though Keycloak is often used by developers and administrators, understanding its benefits can empower regular users to navigate secure systems more effectively!

### Features of Keycloak

Keycloak is an open-source identity and access management (IAM) solution. Here are the key points, presented in bullet format:

**Single Sign-On (SSO)**:

- **Centralized Authentication:** Keycloak provides a unified login experience across multiple applications. Users log in once and gain access to all connected services.
- **Session Management:** Users maintain a single session, reducing the need for repeated logins.

**User Federation**:

- **External Identity Providers:** Keycloak can integrate with external systems (LDAP, Active Directory, social platforms) to federate user identities.
- **Identity Brokering:** Users can log in using their existing accounts from other providers (e.g., Google, Facebook).

**Authentication Mechanisms**:

- **Username/Password:** Traditional login using credentials.
- **Social Logins:** Users can sign in via social media accounts.
- **Multi-Factor Authentication (MFA):** Enhances security by requiring additional verification steps (e.g., SMS codes, authenticator apps).

**Authorization and Fine-Grained Access Control**:

- **Roles and Permissions:** Define roles and associate them with users. Control access based on roles.
- **Scopes and Claims:** Keycloak supports OAuth 2.0 and OpenID Connect, allowing fine-grained control over data access.

**User Self-Service**:

- **Profile Management:** Users can update their profiles, change passwords, and manage sessions.
- **Password Reset:** Self-service password recovery.

**Customizable Themes and Branding**:

- **Login Pages:** Customize the look and feel of login screens.
- **Email Templates:** Personalize email notifications sent by Keycloak.

**Security Features**:

- **Token-Based Authentication:** Uses tokens (JWTs) for secure communication between applications.
- **OAuth 2.0 and OpenID Connect:** Industry-standard protocols for secure authentication and authorization.

**Admin Console and REST API**:

- **Admin Console:** Web-based interface for managing users, roles, clients, and realms.
- **REST API:** Programmatic access for automation and integration.

**Client Adapters**:

- **Java, JavaScript, and More:** Keycloak provides client libraries for various languages and platforms.
- **Adapter Configuration:** Easily secure your applications with Keycloak.

**Events and Auditing**:

- **Audit Logs:** Track user actions, login attempts, and administrative changes.
- **Event Listeners:** React to specific events (e.g., user registration, login).

**Clustering and High Availability**:

- **Distributed Deployment:** Keycloak can be clustered for scalability and fault tolerance.
- **Database Replication:** Support for various databases.

**Open Source Community and Support**:

- **Active Community:** Keycloak benefits from contributions and support from developers worldwide.
- **Documentation and Forums:** Rich resources for learning and troubleshooting.

Remember, Keycloak empowers organizations to manage user identities securely, making it a valuable tool for both developers and administrators!

## Installation

### Git Hub Repos

- **python-keycloak-fast-api:** `https://github.com/raj713335/python-keycloak-fast-api`
- **react-keycloak:** `https://github.com/raj713335/react-keycloak`
- **keycloak-spring-boot:** `https://github.com/raj713335/keycloak-spring-boot`
- **keycloak-angular-app:** `https://github.com/raj713335/keycloak-angular-app`
- **keycloak-demo-event-listener:** `https://github.com/raj713335/keycloak-demo-event-listener`

### Install Keycloak by Docker

> `https://www.keycloak.org/getting-started/getting-started-docker`

To install keycloak using the docker image, you need to pull the image from the Docker Hub and run it with the appropriate environment variables. For example, you can run:

```sh
docker run -d --rm --name keycloak -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=changeit quay.io/keycloak/keycloak:24.0.1 start-dev

docker run -d --rm --name keycloak --network=service-network -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=changeit quay.io/keycloak/keycloak:24.0.1 start-dev
```

To install keycloak using the docker image within an OpenShift runtime, you need to create a new project and deploy the image from the OpenShift catalog. You also need to set the admin user and password as environment variables. For example, you can run:

```sh
oc new-project keycloak
oc new-app --template=keycloak -p KEYCLOAK_USER=admin -p KEYCLOAK_PASSWORD=changeit
```

After installing keycloak, you can access the admin console at `http://localhost:8080/auth/admin/` and log in with the admin user and password you set. You can then create and configure realms, clients, users, roles, and other settings for your keycloak server.

### Install PostgreSQL by Docker

Running PostgreSQL within Docker provides a convenient, isolated, and portable way to manage your database instances, especially for development and testing environments.

```sh
docker volume create postgresql_data
docker run -d --rm --name postgresql -e POSTGRES_PASSWORD=changeit -p 5432:5432 -v postgresql_data:/var/lib/postgresql/data postgres



docker network create service-network

docker volume  create postgres_data
docker volume create pgadm_data

docker run --rm -d --name postgres --network=service-network -e POSTGRES_PASSWORD=changeit123! -p 5432:5432 -v postgres_data:/var/lib/postgresql/data postgres
docker run --rm -d --name pgadmin  --network=service-network -e PGADMIN_DEFAULT_EMAIL=tarsoqueiroz@gmail.com -e PGADMIN_DEFAULT_PASSWORD=changeit123! -p 8432:80 dpage/pgadmin4
```

## That's all

...folks!!!
