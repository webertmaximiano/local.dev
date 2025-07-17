Getting Started with Kubernetes and Traefik
https://doc.traefik.io/traefik/providers/kubernetes-ingress/


Traefik & Kubernetes
The Kubernetes Ingress Controller.

The Traefik Kubernetes Ingress provider is a Kubernetes Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification.

Requirements
Traefik follows the Kubernetes support policy, and supports at least the latest three minor versions of Kubernetes. General functionality cannot be guaranteed for older versions.

Routing Configuration
See the dedicated section in routing.

Enabling and Using the Provider
You can enable the provider in the static configuration:


File (YAML)

providers:
  kubernetesIngress: {}

File (TOML)

CLI
The provider then watches for incoming ingresses events, such as the example below, and derives the corresponding dynamic configuration from it, which in turn creates the resulting routers, services, handlers, etc.


Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foo
  namespace: production

spec:
  rules:
    - host: example.net
      http:
        paths:
          - path: /bar
            pathType: Exact
            backend:
              service:
                name:  service1
                port:
                  number: 80
          - path: /foo
            pathType: Exact
            backend:
              service:
                name:  service1
                port:
                  number: 80
LetsEncrypt Support with the Ingress Provider
By design, Traefik is a stateless application, meaning that it only derives its configuration from the environment it runs in, without additional configuration. For this reason, users can run multiple instances of Traefik at the same time to achieve HA, as is a common pattern in the kubernetes ecosystem.

When using a single instance of Traefik Proxy with Let's Encrypt, you should encounter no issues. However, this could be a single point of failure. Unfortunately, it is not possible to run multiple instances of Traefik 2.0 with Let's Encrypt enabled, because there is no way to ensure that the correct instance of Traefik receives the challenge request, and subsequent responses. Early versions (v1.x) of Traefik used a KV store to attempt to achieve this, but due to sub-optimal performance that feature was dropped in 2.0.

If you need Let's Encrypt with high availability in a Kubernetes environment, we recommend using Traefik Enterprise which includes distributed Let's Encrypt as a supported feature.

If you want to keep using Traefik Proxy, LetsEncrypt HA can be achieved by using a Certificate Controller such as Cert-Manager. When using Cert-Manager to manage certificates, it creates secrets in your namespaces that can be referenced as TLS secrets in your ingress objects.

Provider Configuration
endpoint
Optional, Default=""

The Kubernetes server endpoint URL.

When deployed into Kubernetes, Traefik reads the environment variables KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT or KUBECONFIG to construct the endpoint.

The access token is looked up in /var/run/secrets/kubernetes.io/serviceaccount/token and the SSL CA certificate in /var/run/secrets/kubernetes.io/serviceaccount/ca.crt. Both are mounted automatically when deployed inside Kubernetes.

The endpoint may be specified to override the environment variable values inside a cluster.

When the environment variables are not found, Traefik tries to connect to the Kubernetes API server with an external-cluster client. In this case, the endpoint is required. Specifically, it may be set to the URL used by kubectl proxy to connect to a Kubernetes cluster using the granted authentication and authorization of the associated kubeconfig.


File (YAML)

providers:
  kubernetesIngress:
    endpoint: "http://localhost:8080"
    # ...

File (TOML)

CLI
token
Optional, Default=""

Bearer token used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesIngress:
    token: "mytoken"
    # ...

File (TOML)

CLI
certAuthFilePath
Optional, Default=""

Path to the certificate authority file. Used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesIngress:
    certAuthFilePath: "/my/ca.crt"
    # ...

File (TOML)

CLI
namespaces
Optional, Default: []

Array of namespaces to watch. If left empty, Traefik watches all namespaces.


File (YAML)

providers:
  kubernetesIngress:
    namespaces:
      - "default"
      - "production"
    # ...

File (TOML)

CLI
labelSelector
Optional, Default: ""

A label selector can be defined to filter on specific Ingress objects only. If left empty, Traefik processes all Ingress objects in the configured namespaces.

See label-selectors for details.


File (YAML)

providers:
  kubernetesIngress:
    labelSelector: "app=traefik"
    # ...

File (TOML)

CLI
ingressClass
Optional, Default: ""

Value of kubernetes.io/ingress.class annotation that identifies Ingress objects to be processed.

If the parameter is set, only Ingresses containing an annotation with the same value are processed. Otherwise, Ingresses missing the annotation, having an empty value, or the value traefik are processed.

Example

File (YAML)

providers:
  kubernetesIngress:
    ingressClass: "traefik-internal"
    # ...

File (TOML)

CLI
disableIngressClassLookup
Optional, Default: false

Deprecated
If the parameter is set to true, Traefik will not discover IngressClasses in the cluster. By doing so, it alleviates the requirement of giving Traefik the rights to look IngressClasses up. Furthermore, when this option is set to true, Traefik is not able to handle Ingresses with IngressClass references, therefore such Ingresses will be ignored. Please note that annotations are not affected by this option.


File (YAML)

providers:
  kubernetesIngress:
    disableIngressClassLookup: true
    # ...

File (TOML)

CLI
disableClusterScopeResources
Optional, Default: false

When this parameter is set to true, Traefik will not discover cluster scope resources (IngressClass and Nodes). By doing so, it alleviates the requirement of giving Traefik the rights to look up for cluster resources. Furthermore, Traefik will not handle Ingresses with IngressClass references, therefore such Ingresses will be ignored (please note that annotations are not affected by this option). This will also prevent from using the NodePortLB options on services.


File (YAML)

providers:
  kubernetesIngress:
    disableClusterScopeResources: true
    # ...

File (TOML)

CLI
ingressEndpoint
hostname
Optional, Default: ""

Hostname used for Kubernetes Ingress endpoints.


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      hostname: "example.net"
    # ...

File (TOML)

CLI
ip
Optional, Default: ""

This IP will get copied to Ingress status.loadbalancer.ip, and currently only supports one IP value (IPv4 or IPv6).


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      ip: "1.2.3.4"
    # ...

File (TOML)

CLI
publishedService
Optional, Default: ""

Format: namespace/servicename.

The Kubernetes service to copy status from, depending on the service type:

ClusterIP: The ExternalIPs of the service will be propagated to the ingress status.
NodePort: The ExternalIP addresses of the nodes in the cluster will be propagated to the ingress status.
LoadBalancer: The IPs from the service's loadBalancer.status field (which contains the endpoints provided by the load balancer) will be propagated to the ingress status.
When using third-party tools such as External-DNS, this option enables the copying of external service IPs to the ingress resources.


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      publishedService: "namespace/foo-service"
    # ...

File (TOML)

CLI
throttleDuration
Optional, Default: 0

The throttleDuration option defines how often the provider is allowed to handle events from Kubernetes. This prevents a Kubernetes cluster that updates many times per second from continuously changing your Traefik configuration.

If left empty, the provider does not apply any throttling and does not drop any Kubernetes events.

The value of throttleDuration should be provided in seconds or as a valid duration format, see time.ParseDuration.


File (YAML)

providers:
  kubernetesIngress:
    throttleDuration: "10s"
    # ...

File (TOML)

CLI
allowEmptyServices
Optional, Default: false

If the parameter is set to true, it allows the creation of an empty servers load balancer if the targeted Kubernetes service has no endpoints available. This results in 503 HTTP responses instead of 404 ones.


File (YAML)

providers:
  kubernetesIngress:
    allowEmptyServices: true
    # ...

File (TOML)

CLI
allowExternalNameServices
Optional, Default: false

If the parameter is set to true, Ingresses are able to reference ExternalName services.


File (YAML)

providers:
  kubernetesIngress:
    allowExternalNameServices: true
    # ...

File (TOML)

CLI
nativeLBByDefault
Optional, Default: false

Defines whether to use Native Kubernetes load-balancing mode by default. For more information, please check out the traefik.ingress.kubernetes.io/service.nativelb service annotation documentation.


File (YAML)

providers:
  kubernetesIngress:
    nativeLBByDefault: true
    # ...

File (TOML)

CLI
Further
To learn more about the various aspects of the Ingress specification that Traefik supports, many examples of Ingresses definitions are located in the test examples of the Traefik repository.


Kubernetes is a first-class citizen in Traefik, offering native support for Kubernetes resources and the latest Kubernetes standards. Whether you're using Traefik's IngressRoute CRD, Ingress or the Kubernetes Gateway API, Traefik provides a seamless experience for managing your Kubernetes traffic.

This guide shows you how to:

Create a Kubernetes cluster using k3d
Install Traefik using Helm
Expose the Traefik dashboard
Deploy a sample application
Configure basic routing with IngressRoute and Gateway API
Prerequisites
Kubernetes
Helm 3
kubectl
k3d (for local cluster creation)
Create a Kubernetes Cluster¶
Using k3d
Create a cluster with the following command. This command:

Creates a k3d cluster named "traefik"
Maps ports 80, 443, and 8000 to the loadbalancer for accessing services
Disables the built-in Traefik ingress controller to avoid conflicts

k3d cluster create traefik \
  --port 80:80@loadbalancer \
  --port 443:443@loadbalancer \
  --port 8000:8000@loadbalancer \
  --k3s-arg "--disable=traefik@server:0"
Configure kubectl:


kubectl cluster-info --context k3d-traefik
Install Traefik
Using Helm Values File
Add the Traefik Helm repository:


helm repo add traefik https://traefik.github.io/charts
helm repo update
Create a values file. This configuration:

Maps ports 80 and 443 to the web and websecure entrypoints
Enables the dashboard with a specific hostname rule
Enables the Kubernetes Gateway API provider
Allows the Gateway to expose HTTPRoutes from all namespaces

# values.yaml
ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`dashboard.localhost`)
    entryPoints:
      - web
providers:
  kubernetesGateway:
    enabled: true
gateway:
  namespacePolicy: All
Info

The KubernetesCRD provider is enabled by default when using the Helm chart so we don't need to set it in the values file.

Install Traefik:


helm install traefik traefik/traefik -f values.yaml --wait
Using Helm CLI Arguments
Alternatively, you can install Traefik using CLI arguments. This command:

Maps ports 30000 and 30001 to the web and websecure entrypoints
Enables the dashboard with a specific hostname rule
Enables the Kubernetes Gateway API provider
Allows the Gateway to expose HTTPRoutes from all namespaces

helm install traefik traefik/traefik --wait \
  --set ingressRoute.dashboard.enabled=true \
  --set ingressRoute.dashboard.matchRule='Host(`dashboard.localhost`)' \
  --set ingressRoute.dashboard.entryPoints={web} \
  --set providers.kubernetesGateway.enabled=true \
  --set gateway.namespacePolicy=All
Info

The KubernetesCRD provider is enabled by default when using the Helm chart so we don't need to set it in the CLI arguments.

When Traefik is installed with the Gateway API provider enabled, it automatically creates a default GatewayClass named traefik:


kubectl describe GatewayClass traefik
Expose the Dashboard
The dashboard is exposed with an IngressRoute provided by the Chart, as we defined in the helm values during installation.

Access it at:

http://dashboard.localhost/dashboard/

Traefik Dashboard Screenshot

Deploy a Sample Application
Create a deployment:


# whoami.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  replicas: 2
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami
          ports:
            - containerPort: 80
Create a service:


# whoami-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  ports:
    - port: 80
  selector:
    app: whoami
Apply the manifests:


kubectl apply -f whoami.yaml
kubectl apply -f whoami-service.yaml
Exposing the Application Using an IngressRoute (CRD)
Create an IngressRoute:


# whoami-ingressroute.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: whoami
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`whoami.localhost`)
      kind: Rule
      services:
        - name: whoami
          port: 80
Apply the manifest:


kubectl apply -f whoami-ingressroute.yaml
Test Your Setup
You can use the following curl command to verify that the application is correctly exposed:


curl http://whoami.localhost

Hostname: whoami-76c9859cfc-6v8hh
IP: 127.0.0.1
IP: ::1
IP: 10.42.0.11
IP: fe80::20ad:eeff:fe44:a63
RemoteAddr: 10.42.0.9:38280
GET / HTTP/1.1
Host: whoami.localhost
User-Agent: curl/8.7.1
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 127.0.0.1
X-Forwarded-Host: whoami.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-598946cd7-zds59
X-Real-Ip: 127.0.0.1
You can also visit http://whoami.localhost in a browser to verify that the application is exposed correctly:

whoami application Screenshot

Exposing the Application Using the Gateway API
Traefik supports the Kubernetes Gateway API specification, which provides a more standardized way to configure ingress in Kubernetes. When we installed Traefik earlier, we enabled the Gateway API provider. You can verify this in the providers section of the Traefik dashboard.

Providers Section Screenshot

To use the Gateway API:

Install the Gateway API CRDs in your cluster:


kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
Create an HTTPRoute. This configuration:

Creates an HTTPRoute named "whoami"
Attaches it to the default Gateway that Traefik created during installation
Configures routing for the hostname "whoami-gatewayapi.localhost"
Routes all traffic to the whoami service on port 80

# httproute.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami
spec:
  parentRefs:
    - name: traefik-gateway
  hostnames:
    - "whoami-gatewayapi.localhost"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: whoami
          port: 80
Apply the manifest:


kubectl apply -f httproute.yaml
Test Your Setup
You can use the following curl command to verify that the application is correctly exposed:


curl http://whoami-gatewayapi.localhost

Hostname: whoami-76c9859cfc-6v8hh
IP: 127.0.0.1
IP: ::1
IP: 10.42.0.11
IP: fe80::20ad:eeff:fe44:a63
RemoteAddr: 10.42.0.9:38280
GET / HTTP/1.1
Host: whoami.localhost
User-Agent: curl/8.7.1
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 127.0.0.1
X-Forwarded-Host: whoami.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-598946cd7-zds59
X-Real-Ip: 127.0.0.1
You can now visit http://whoami.localhost in your browser to verify that the application is exposed correctly:

whoami application Screenshot

If you navigate to the HTTP Routes section of the traefik dashboard, you can see that the whoami.localhost route is managed by the Traefik Kubernetes Gateway API provider:

Traefik Dashboard HTTP Routes Section Screenshot

That's it! You've successfully deployed Traefik and configured routing in a Kubernetes cluster.

Next Steps
# Configure TLS
TLS
Transport Layer Security

Certificates Definition
Automated
See the Let's Encrypt page.

User defined
To add / remove TLS certificates, even when Traefik is already running, their definition can be added to the dynamic configuration, in the [[tls.certificates]] section:


File (YAML)

# Dynamic configuration

tls:
  certificates:
    - certFile: /path/to/domain.cert
      keyFile: /path/to/domain.key
    - certFile: /path/to/other-domain.cert
      keyFile: /path/to/other-domain.key

File (TOML)
Restriction

In the above example, we've used the file provider to handle these definitions. It is the only available method to configure the certificates (as well as the options and the stores). However, in Kubernetes, the certificates can and must be provided by secrets.

Certificates Stores
In Traefik, certificates are grouped together in certificates stores, which are defined as such:


File (YAML)

# Dynamic configuration

tls:
  stores:
    default: {}

File (TOML)
Restriction

Any store definition other than the default one (named default) will be ignored, and there is therefore only one globally available TLS store.

In the tls.certificates section, a list of stores can then be specified to indicate where the certificates should be stored:


File (YAML)

# Dynamic configuration

tls:
  certificates:
    - certFile: /path/to/domain.cert
      keyFile: /path/to/domain.key
      stores:
        - default
    # Note that since no store is defined,
    # the certificate below will be stored in the `default` store.
    - certFile: /path/to/other-domain.cert
      keyFile: /path/to/other-domain.key

File (TOML)
Restriction

The stores list will actually be ignored and automatically set to ["default"].

Default Certificate
Traefik can use a default certificate for connections without a SNI, or without a matching domain. This default certificate should be defined in a TLS store:


File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: default
  namespace: default

spec:
  defaultCertificate:
    secretName: default-certificate

---
apiVersion: v1
kind: Secret
metadata:
  name: default-certificate
  namespace: default

type: Opaque
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0=
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
If no defaultCertificate is provided, Traefik will use the generated one.

ACME Default Certificate
You can configure Traefik to use an ACME provider (like Let's Encrypt) to generate the default certificate. The configuration to resolve the default certificate should be defined in a TLS store:

Precedence with the defaultGeneratedCert option

The defaultGeneratedCert definition takes precedence over the ACME default certificate configuration.


File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: default
  namespace: default

spec:
  defaultGeneratedCert:
    resolver: myresolver
    domain:
      main: example.org
      sans:
        - foo.example.org
        - bar.example.org

Docker & Swarm
TLS Options
The TLS options allow one to configure some parameters of the TLS connection.

'default' TLS Option

The default option is special. When no tls options are specified in a tls router, the default option is used.
When specifying the default option explicitly, make sure not to specify provider namespace as the default option does not have one.
Conversely, for cross-provider references, for example, when referencing the file provider from a docker label, you must specify the provider namespace, for example:
traefik.http.routers.myrouter.tls.options=myoptions@file

TLSOption in Kubernetes

When using the TLSOption resource in Kubernetes, one might setup a default set of options that, if not explicitly overwritten, should apply to all ingresses.
To achieve that, you'll have to create a TLSOption resource with the name default. There may exist only one TLSOption with the name default (across all namespaces) - otherwise they will be dropped.
To explicitly use a different TLSOption (and using the Kubernetes Ingress resources) you'll have to add an annotation to the Ingress in the following form: traefik.ingress.kubernetes.io/router.tls.options: <resource-namespace>-<resource-name>@kubernetescrd

Minimum TLS Version

File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: default
  namespace: default

spec:
  minVersion: VersionTLS12

---
apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: mintls13
  namespace: default

spec:
  minVersion: VersionTLS13
Maximum TLS Version
We discourage the use of this setting to disable TLS1.3.

The recommended approach is to update the clients to support TLS1.3.


File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: default
  namespace: default

spec:
  maxVersion: VersionTLS13

---
apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: maxtls12
  namespace: default

spec:
  maxVersion: VersionTLS12
Cipher Suites
See cipherSuites for more information.


File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: default
  namespace: default

spec:
  cipherSuites:
    - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
TLS 1.3

Cipher suites defined for TLS 1.2 and below cannot be used in TLS 1.3, and vice versa. (https://tools.ietf.org/html/rfc8446)
With TLS 1.3, the cipher suites are not configurable (all supported cipher suites are safe in this case). https://golang.org/doc/go1.12#tls_1_3

Curve Preferences
This option allows to set the preferred elliptic curves in a specific order.

The names of the curves defined by crypto (e.g. CurveP521) and the RFC defined names (e. g. secp521r1) can be used.

See CurveID for more information.


File (YAML)

File (TOML)

Kubernetes

apiVersion: traefik.io/v1alpha1
kind: TLSOption
metadata:
  name: default
  namespace: default

spec:
  curvePreferences:
    - CurveP521
    - CurveP384
Strict SNI Checking
With strict SNI checking enabled, Traefik won't allow connections from clients that do not specify a server_name extension or don't match any of the configured certificates. The default certificate is irrelevant on that matter.


File (YAML)

# Dynamic configuration

tls:
  options:
    default:
      sniStrict: true

File (TOML)

Kubernetes
ALPN Protocols
Optional, Default="h2, http/1.1, acme-tls/1"

This option allows to specify the list of supported application level protocols for the TLS handshake, in order of preference. If the client supports ALPN, the selected protocol will be one from this list, and the connection will fail if there is no mutually supported protocol.


File (YAML)

# Dynamic configuration

tls:
  options:
    default:
      alpnProtocols:
        - http/1.1
        - h2

File (TOML)

Kubernetes
Client Authentication (mTLS)
Traefik supports mutual authentication, through the clientAuth section.

For authentication policies that require verification of the client certificate, the certificate authority for the certificates should be set in clientAuth.caFiles.

In Kubernetes environment, CA certificate can be set in clientAuth.secretNames. See TLSOption resource for more details.

The clientAuth.clientAuthType option governs the behaviour as follows:

NoClientCert: disregards any client certificate.
RequestClientCert: asks for a certificate but proceeds anyway if none is provided.
RequireAnyClientCert: requires a certificate but does not verify if it is signed by a CA listed in clientAuth.caFiles or in clientAuth.secretNames.
VerifyClientCertIfGiven: if a certificate is provided, verifies if it is signed by a CA listed in clientAuth.caFiles or in clientAuth.secretNames. Otherwise proceeds without any certificate.
RequireAndVerifyClientCert: requires a certificate, which must be signed by a CA listed in clientAuth.caFiles or in clientAuth.secretNames.

File (YAML)

# Dynamic configuration

tls:
  options:
    default:
      clientAuth:
        # in PEM format. each file can contain multiple CAs.
        caFiles:
          - tests/clientca1.crt
          - tests/clientca2.crt
        clientAuthType: RequireAndVerifyClientCert

File (TOML)

Kubernetes
Disable Session Tickets
Optional, Default="false"

When set to true, Traefik disables the use of session tickets, forcing every client to perform a full TLS handshake instead of resuming sessions.


File (YAML)

# Dynamic configuration

tls:
  options:
    default:
      disableSessionTickets: true

File (TOML)

Kubernetes


# Set up Middlewares

Middlewares
Tweaking the Request

Overview

Attached to the routers, pieces of middleware are a means of tweaking the requests before they are sent to your service (or before the answer from the services are sent to the clients).

There are several available middleware in Traefik, some can modify the request, the headers, some are in charge of redirections, some add authentication, and so on.

Middlewares that use the same protocol can be combined into chains to fit every scenario.

Provider Namespace

Be aware of the concept of Providers Namespace described in the Configuration Discovery section. It also applies to Middlewares.

Configuration Example

Docker & Swarm

IngressRoute

---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: stripprefix
spec:
  stripPrefix:
    prefixes:
      - /stripit

---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ingressroute
spec:
# more fields...
  routes:
    # more fields...
    middlewares:
      - name: stripprefix

Consul Catalog

File (YAML)

File (TOML)
Available Middlewares
A list of HTTP middlewares can be found here.

A list of TCP middlewares can be found here.

# Enable Metrics
Observability Overview
Traefik Proxy provides comprehensive monitoring and observability capabilities to maintain reliability and efficiency:

Logs and Access Logs provide real-time insight into the health of your system. They enable swift error detection and intervention through alerts. By centralizing logs, you can streamline the debugging process during incident resolution.

Metrics offer a comprehensive view of your infrastructure's health. They allow you to monitor critical indicators like incoming traffic volume. Metrics graphs and visualizations are helpful during incident triage in understanding the causes and implementing proactive measures.

Tracing enables tracking the flow of operations within your system. Using traces and spans, you can identify performance bottlenecks and pinpoint applications causing slowdowns to optimize response times effectively.

Configuration Example
You can enable access logs, metrics, and tracing globally:


Structured (YAML)

accessLog: {}

metrics:
  otlp: {}

tracing: {}

Structured (TOML)

Helm Chart Values
You can disable access logs, metrics, and tracing for a specific entrypoint:


Structured (YAML)

entryPoints:
  EntryPoint0:
    address: ':8000/udp'
    observability:
      accessLogs: false
      tracing: false
      metrics: false

Structured (TOML)

Helm Chart Values
Note

A router with its own observability configuration will override the global default.
Logs
Logs concern everything that happens to Traefik itself (startup, configuration, events, shutdown, and so on).

Configuration Example
To enable and configure logs in Traefik Proxy, you can use the static configuration file or Helm values if you are using the Helm chart.


Structured (YAML)

log:
  filePath: "/path/to/log-file.log"
  format: json
  level: INFO

Structured (TOML)

Helm Chart Values
Access Logs
Access logs concern everything that happens to the requests handled by Traefik.

Configuration Example
To enable and configure access logs in Traefik Proxy, you can use the static configuration file or Helm values if you are using the Helm chart.

The following example enables access logs in JSON format, filters them to only include specific status codes, and customizes the fields that are kept or dropped.


Structured (YAML)

accessLog:
  format: json
  filters:
    statusCodes:
      - "200"
      - "400-404"
      - "500-503"
  fields:
    names:
      ClientUsername: drop
    headers:
      defaultMode: keep
      names:
        User-Agent: redact
        Content-Type: keep

Structured (TOML)

Helm Chart Values
Per-Router Access Logs
You can enable or disable access logs for a specific router. This is useful for turning off logging for noisy routes while keeping it on globally.

Here's an example of disabling access logs on a specific router:


Structured (YAML)

http:
  routers:
    my-router:
      rule: "Host(`example.com`)"
      service: my-service
      observability:
        accessLogs: false

Structured (TOML)

Kubernetes

Labels

Tags
When the observability options are not defined on a router, it inherits the behavior from the entrypoint's observability configuration, or the global one.

Log Formats
Traefik Proxy supports the following log formats:

Common Log Format (CLF)
JSON
Access Log Filters
You can configure Traefik Proxy to only record access logs for requests that match certain criteria. This is useful for reducing the volume of logs and focusing on specific events.

The available filters are:

Status Codes: Keep logs only for requests with specific HTTP status codes or ranges (e.g., 200, 400-404).
Retry Attempts: Keep logs only when a request retry has occurred.
Minimum Duration: Keep logs only for requests that take longer than a specified duration.
Log Fields Customization
When using the json format, you can customize which fields are included in your access logs.

Request Fields: You can choose to keep, drop, or redact any of the standard request fields. A complete list of available fields like ClientHost, RequestMethod, and Duration can be found in the reference documentation.
Request Headers: You can also specify which request headers should be included in the logs, and whether their values should be kept, dropped, or redacted.
Info

For detailed configuration options, refer to the reference documentation.
Metrics
Metrics in Traefik Proxy offer a comprehensive view of your infrastructure's health. They allow you to monitor critical indicators like incoming traffic volume. Metrics graphs and visualizations are helpful during incident triage in understanding the causes and implementing proactive measures.

Available Metrics Providers
Traefik Proxy supports the following metrics providers:

OpenTelemetry
Prometheus
Datadog
InfluxDB 2.X
StatsD
Configuration
To enable metrics in Traefik Proxy, you need to configure the metrics provider in your static configuration file or helm values if you are using the Helm chart. The following example shows how to configure the OpenTelemetry provider to send metrics to a collector.


Structured (YAML)

metrics:
  otlp:
    http:
      endpoint: http://myotlpcollector:4318/v1/metrics

Structured (TOML)

Helm Chart Values
Per-Router Metrics
You can enable or disable metrics collection for a specific router. This can be useful for excluding certain routes from your metrics data.

Here's an example of disabling metrics on a specific router:


Structured (YAML)

Structured (TOML)

Kubernetes

# ingressroute.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-router
spec:
  routes:
    - kind: Rule
      match: Host(`example.com`)
      services:
        - name: my-service
          port: 80
      observability:
        metrics: false

Labels

Tags
When the observability options are not defined on a router, it inherits the behavior from the entrypoint's observability configuration, or the global one.

Info
Tracing
Tracing in Traefik Proxy allows you to track the flow of operations within your system. Using traces and spans, you can identify performance bottlenecks and pinpoint applications causing slowdowns to optimize response times effectively.

Traefik Proxy uses OpenTelemetry to export traces. OpenTelemetry is an open-source observability framework. You can send traces to an OpenTelemetry collector, which can then export them to a variety of backends like Jaeger, Zipkin, or Datadog.

Configuration
To enable tracing in Traefik Proxy, you need to configure it in your static configuration file or Helm values if you are using the Helm chart. The following example shows how to configure the OpenTelemetry provider to send traces to a collector via HTTP.


Structured (YAML)

tracing:
  otlp:
    http:
      endpoint: http://myotlpcollector:4318/v1/traces

Structured (TOML)

Helm Chart Values
Info

For detailed configuration options, refer to the tracing reference documentation.


Learn more about Kubernetes CRD provider
Learn more about Kubernetes Gateway API provider
{!traefik-for-business-applications.md!}

# traefik helm chart exemplos
# Install as a DaemonSet

Default install is using a `Deployment` but it's possible to use `DaemonSet`

```yaml
deployment:
  kind: DaemonSet
```

# Configure Traefik Pod parameters

## Extending /etc/hosts records

In some specific cases, you'll need to add extra records to the `/etc/hosts` file for the Traefik containers.
You can configure it using [hostAliases](https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/):

```yaml
deployment:
  hostAliases:
  - ip: "127.0.0.1" # this is an example
    hostnames:
     - "foo.local"
     - "bar.local"
```
## Extending DNS config

In order to configure additional DNS servers for your traefik pod, you can use `dnsConfig` option:

```yaml
deployment:
  dnsConfig:
    nameservers:
      - 192.0.2.1 # this is an example
    searches:
      - ns1.svc.cluster-domain.example
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

# Install in a dedicated namespace, with limited RBAC

Default install is using Cluster-wide RBAC but it can be restricted to target namespace.

```yaml
rbac:
  namespaced: true
```

# Install with auto-scaling

When enabling [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
to adjust replicas count according to CPU Usage, you'll need to set resources and nullify replicas.

```yaml
deployment:
  replicas: null
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"
autoscaling:
  enabled: true
  maxReplicas: 2
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

# Install with Argo Rollouts

When using [ArgoCD Rollouts](https://argoproj.github.io/rollouts/), one can delegate replica management to a `Rollout` resource, enabling progressive delivery strategies like canary and blue-green deployments.
In order to delegate replica management, `deployment.replicas` should be set to `0` and the `Rollout` resource can be defined in a separate YAML or in `extraObjects`.

```yaml
deployment:
  replicas: 0
autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 50
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
extraObjects:
  - apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    metadata:
      name: "{{ template \"traefik.fullname\" . }}"
    spec:
      workloadRef:
        apiVersion: apps/v1
        kind: Deployment
        name: "{{ template \"traefik.fullname\" . }}"
      strategy:
        canary:
          steps:
          - setWeight: 10
          - pause:
              duration: 5m
```

# Access Traefik dashboard without exposing it

This Chart does not expose the Traefik local dashboard by default. It's explained in upstream [documentation](https://doc.traefik.io/traefik/operations/api/) why:

> Enabling the API in production is not recommended, because it will expose all configuration elements, including sensitive data.

It says also:

> In production, it should be at least secured by authentication and authorizations.

Thus, there are multiple ways to expose the dashboard. For instance, after enabling the creation of dashboard `IngressRoute` in the values:

```yaml
ingressRoute:
  dashboard:
    enabled: true
```

The traefik admin port can be forwarded locally. Assuming the default `traefik` namespace is used:

```bash
NAMESPACE=traefik
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n $NAMESPACE) 8080:8080 -n $NAMESPACE
```

This command makes the dashboard accessible through the URL: http://127.0.0.1:8080/dashboard/

> [!IMPORTANT]
> Note that the slash is required.

# Redirect permanently traffic from http to https

It's possible to redirect all incoming requests on an entrypoint to an other entrypoint.

```yaml
ports:
  web:
    redirections:
      entryPoint:
        to: websecure
        scheme: https
        permanent: true
```

# Publish and protect Traefik Dashboard with basic Auth

To expose the dashboard in a secure way as [recommended](https://doc.traefik.io/traefik/operations/dashboard/#dashboard-router-rule)
in the documentation, it may be useful to override the router rule to specify
a domain to match, or accept requests on the root path (/) in order to redirect
them to /dashboard/.

```yaml
# Create an IngressRoute for the dashboard
ingressRoute:
  dashboard:
    enabled: true
    # Custom match rule with host domain
    matchRule: Host(`traefik-dashboard.example.com`)
    entryPoints: ["websecure"]
    # Add custom middlewares : authentication and redirection
    middlewares:
      - name: traefik-dashboard-auth

# Create the custom middlewares used by the IngressRoute dashboard (can also be created in another way).
# /!\ Yes, you need to replace "changeme" password with a better one. /!\
extraObjects:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: traefik-dashboard-auth-secret
    type: kubernetes.io/basic-auth
    stringData:
      username: admin
      password: changeme

  - apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: traefik-dashboard-auth
    spec:
      basicAuth:
        secret: traefik-dashboard-auth-secret
```

# Publish and protect Traefik Dashboard with an Ingress

To expose the dashboard without IngressRoute, it's more complicated and less
secure. You'll need to create an internal Service exposing Traefik API with
special _traefik_ entrypoint. This internal Service can be created from an other tool, with the `extraObjects` section or using [custom services](#add-custom-internal-services).

You'll need to double check:
1. Service selector with your setup.
2. Middleware annotation on the ingress, _default_ should be replaced with traefik's namespace

```yaml
ingressRoute:
  dashboard:
    enabled: false
additionalArguments:
- "--api.insecure=true"
# Create the service, middleware and Ingress used to expose the dashboard (can also be created in another way).
# /!\ Yes, you need to replace "changeme" password with a better one. /!\
extraObjects:
  - apiVersion: v1
    kind: Service
    metadata:
      name: traefik-api
    spec:
      type: ClusterIP
      selector:
        app.kubernetes.io/name: traefik
        app.kubernetes.io/instance: traefik-default
      ports:
      - port: 8080
        name: traefik
        targetPort: 8080
        protocol: TCP

  - apiVersion: v1
    kind: Secret
    metadata:
      name: traefik-dashboard-auth-secret
    type: kubernetes.io/basic-auth
    stringData:
      username: admin
      password: changeme

  - apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: traefik-dashboard-auth
    spec:
      basicAuth:
        secret: traefik-dashboard-auth-secret

  - apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: traefik-dashboard
      annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
        traefik.ingress.kubernetes.io/router.middlewares: default-traefik-dashboard-auth@kubernetescrd
    spec:
      rules:
      - host: traefik-dashboard.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: traefik-api
                port:
                  name: traefik
```


# Install on AWS

It can use [native AWS support](https://kubernetes.io/docs/concepts/services-networking/service/#aws-nlb-support) on Kubernetes

```yaml
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
```

Or if [AWS LB controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/#legacy-cloud-provider) is installed :
```yaml
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb-ip
```

# Install on GCP

A [regional IP with a Service](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip#use_a_service) can be used
```yaml
service:
  spec:
    loadBalancerIP: "1.2.3.4"
```

Or a [global IP on Ingress](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip#use_an_ingress)
```yaml
service:
  type: NodePort
extraObjects:
  - apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: traefik
      annotations:
        kubernetes.io/ingress.global-static-ip-name: "myGlobalIpName"
    spec:
      defaultBackend:
        service:
          name: traefik
          port:
            number: 80
```

Or a [global IP on a Gateway](https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-gateways) with continuous HTTPS encryption.

```yaml
ports:
  websecure:
    appProtocol: HTTPS # Hint for Google L7 load balancer
service:
  type: ClusterIP
extraObjects:
- apiVersion: gateway.networking.k8s.io/v1beta1
  kind: Gateway
  metadata:
    name: traefik
    annotations:
      networking.gke.io/certmap: "myCertificateMap"
  spec:
    gatewayClassName: gke-l7-global-external-managed
    addresses:
    - type: NamedAddress
      value: "myGlobalIPName"
    listeners:
    - name: https
      protocol: HTTPS
      port: 443
- apiVersion: gateway.networking.k8s.io/v1beta1
  kind: HTTPRoute
  metadata:
    name: traefik
  spec:
    parentRefs:
    - kind: Gateway
      name: traefik
    rules:
    - backendRefs:
      - name: traefik
        port: 443
- apiVersion: networking.gke.io/v1
  kind: HealthCheckPolicy
  metadata:
    name: traefik
  spec:
    default:
      config:
        type: HTTP
        httpHealthCheck:
          port: 8080
          requestPath: /ping
    targetRef:
      group: ""
      kind: Service
      name: traefik
```

# Install on Azure

A [static IP on a resource group](https://learn.microsoft.com/en-us/azure/aks/static-ip) can be used:

```yaml
service:
  spec:
    loadBalancerIP: "1.2.3.4"
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: myResourceGroup
```

Here is a more complete example, using also native Let's encrypt feature of Traefik Proxy with Azure DNS:

```yaml
persistence:
  enabled: true
  size: 128Mi
certificatesResolvers:
  letsencrypt:
    acme:
      email: "{{ letsencrypt_email }}"
      #caServer: https://acme-v02.api.letsencrypt.org/directory # Production server
      caServer: https://acme-staging-v02.api.letsencrypt.org/directory # Staging server
      dnsChallenge:
        provider: azuredns
      storage: /data/acme.json
env:
  - name: AZURE_CLIENT_ID
    value: "{{ azure_dns_challenge_application_id }}"
  - name: AZURE_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: azuredns-secret
        key: client-secret
  - name: AZURE_SUBSCRIPTION_ID
    value: "{{ azure_subscription_id }}"
  - name: AZURE_TENANT_ID
    value: "{{ azure_tenant_id }}"
  - name: AZURE_RESOURCE_GROUP
    value: "{{ azure_resource_group }}"
deployment:
  initContainers:
    - name: volume-permissions
      image: busybox:latest
      command: ["sh", "-c", "ls -la /; touch /data/acme.json; chmod -v 600 /data/acme.json"]
      volumeMounts:
      - mountPath: /data
        name: data
podSecurityContext:
  fsGroup: 65532
  fsGroupChangePolicy: "OnRootMismatch"
service:
  spec:
    type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: "{{ azure_node_resource_group }}"
    service.beta.kubernetes.io/azure-pip-name: "{{ azure_resource_group }}"
    service.beta.kubernetes.io/azure-dns-label-name: "{{ azure_resource_group }}"
    service.beta.kubernetes.io/azure-allowed-ip-ranges: "{{ ip_range | join(',') }}"
extraObjects:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: azuredns-secret
      namespace: traefik
    type: Opaque
    stringData:
      client-secret: "{{ azure_dns_challenge_application_secret }}"
```

# Use an IngressClass

Default install comes with an `IngressClass` resource that can be enabled on providers.

Here's how one can enable it on CRD & Ingress Kubernetes provider:

```yaml
ingressClass:
  name: traefik
providers:
  kubernetesCRD:
    ingressClass: traefik
  kubernetesIngress:
    ingressClass: traefik
```

# Use HTTP3

By default, it will use a Load balancers with mixed protocols on `websecure`
entrypoint. They are available since v1.20 and in beta as of Kubernetes v1.24.
Availability may depend on your Kubernetes provider.

When using TCP and UDP with a single service, you may encounter [this issue](https://github.com/kubernetes/kubernetes/issues/47249#issuecomment-587960741) from Kubernetes.
If you want to avoid this issue, you can set `ports.websecure.http3.advertisedPort`
to an other value than 443

```yaml
ports:
  websecure:
    http3:
      enabled: true
```

You can also create two `Service`, one for TCP and one for UDP:

```yaml
ports:
  websecure:
    http3:
      enabled: true
service:
  single: false
```

# Use PROXY protocol on Digital Ocean

PROXY protocol is a protocol for sending client connection information, such as origin IP addresses and port numbers, to the final backend server, rather than discarding it at the load balancer.

```yaml
.DOTrustedIPs: &DOTrustedIPs
  - 127.0.0.1/32
  # IP range Load Balancer is on
  - 10.0.0.0/8
  # IP range of private (VPC) interface - CHANGE THIS TO YOUR NETWORK SETTINGS
  # This is needed when "externalTrafficPolicy: Cluster" is specified, as inbound traffic from the load balancer to a Traefik instance could be redirected from another cluster node on the way through.
  - 172.16.0.0/12

service:
  enabled: true
  type: LoadBalancer
  annotations:
    # This will tell DigitalOcean to enable the proxy protocol.
    service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "true"
  spec:
    # This is the default and should stay as cluster to keep the DO health checks working.
    externalTrafficPolicy: Cluster

ports:
  web:
    forwardedHeaders:
      trustedIPs: *DOTrustedIPs
    proxyProtocol:
      trustedIPs: *DOTrustedIPs
  websecure:
    forwardedHeaders:
      trustedIPs: *DOTrustedIPs
    proxyProtocol:
      trustedIPs: *DOTrustedIPs
```

# Using plugins

This chart follows common security practices: it runs as non-root with a readonly root filesystem.
When enabling a plugin, this Chart provides by default an `emptyDir` for plugin storage.

Here is an example with [crowdsec](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin/blob/main/examples/kubernetes/README.md) plugin:

```yaml
experimental:
  plugins:
    demo:
      moduleName: github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin
      version: v1.3.5
```

When persistence is needed, this `emptyDir` can be replaced with a PVC by adding:

```yaml
deployment:
  additionalVolumes:
  - name: plugins
    persistentVolumeClaim:
      claimName: my-plugins-vol
additionalVolumeMounts:
- name: plugins
  mountPath: /plugins-storage
extraObjects:
  - kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: my-plugins-vol
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
```

## Local Plugins

To develop or test plugins without pushing them to a public registry, you can load plugin source code directly from your local filesystem.

```yaml
experimental:
  localPlugins:
    local-demo:
      moduleName: github.com/traefik/localplugindemo
      mountPath: /plugins-local/src/github.com/traefik/localplugindemo
      hostPath: /path/to/plugin-source
```

>[!NOTE]
> The ``hostPath`` must point to a directory containing the plugin source code and a valid ``go.mod`` file. The ``moduleName`` must match the module name specified in the ``go.mod`` file.

>[!IMPORTANT]
> When using ``hostPath`` volumes, the plugin source code must be available on every node where Traefik pods might be scheduled.

# Use Traefik native Let's Encrypt integration, without cert-manager

In Traefik Proxy, ACME certificates are stored in a JSON file.

This file needs to have 0600 permissions, meaning, only the owner of the file has full read and write access to it.
By default, Kubernetes recursively changes ownership and permissions for the content of each volume.

=> An initContainer can be used to avoid an issue on this sensitive file.
See [#396](https://github.com/traefik/traefik-helm-chart/issues/396) for more details.

Once the provider is ready, it can be used in an `IngressRoute`:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: [...]
spec:
  entryPoints: [...]
  routes: [...]
  tls:
    certResolver: letsencrypt
```

:information_source: Change `apiVersion` to `traefik.containo.us/v1alpha1` for charts prior to v28.0.0

See [the list of supported providers](https://doc.traefik.io/traefik/https/acme/#providers) for others.

## Example with CloudFlare

This example needs a CloudFlare token in a Kubernetes `Secret` and a working `StorageClass`.

**Step 1**: Create `Secret` with CloudFlare token:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare
type: Opaque
stringData:
  token: {{ SET_A_VALID_TOKEN_HERE }}
```

**Step 2**:

```yaml
persistence:
  enabled: true
  storageClass: xxx
certificatesResolvers:
  letsencrypt:
    acme:
      dnsChallenge:
        provider: cloudflare
      storage: /data/acme.json
env:
  - name: CF_DNS_API_TOKEN
    valueFrom:
      secretKeyRef:
        name: cloudflare
        key: token
deployment:
  initContainers:
    - name: volume-permissions
      image: busybox:latest
      command: ["sh", "-c", "touch /data/acme.json; chmod -v 600 /data/acme.json"]
      volumeMounts:
      - mountPath: /data
        name: data
podSecurityContext:
  fsGroup: 65532
  fsGroupChangePolicy: "OnRootMismatch"
```

>[!NOTE]
> With [Traefik Hub](https://traefik.io/traefik-hub/), certificates can be stored as a `Secret` on Kubernetes with `distributedAcme` resolver.

# Provide default certificate with cert-manager and CloudFlare DNS

Setup:

* cert-manager installed in `cert-manager` namespace
* A cloudflare account on a DNS Zone

**Step 1**: Create `Secret` and `Issuer` needed by `cert-manager` with your API Token.
See [cert-manager documentation](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)
for creating this token with needed rights:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare
  namespace: traefik
type: Opaque
stringData:
  api-token: XXX
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: cloudflare
  namespace: traefik
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: email@example.com
    privateKeySecretRef:
      name: cloudflare-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare
              key: api-token
```

**Step 2**: Create `Certificate` in traefik namespace

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-example-com
  namespace: traefik
spec:
  secretName: wildcard-example-com-tls
  dnsNames:
    - "example.com"
    - "*.example.com"
  issuerRef:
    name: cloudflare
    kind: Issuer
```

**Step 3**: Check that it's ready

```bash
kubectl get certificate -n traefik
```

If needed, logs of cert-manager pod can give you more information

**Step 4**: Use it on the TLS Store in **values.yaml** file for this Helm Chart

```yaml
tlsStore:
  default:
    defaultCertificate:
      secretName: wildcard-example-com-tls
```

**Step 5**: Enjoy. All your `IngressRoute` use this certificate by default now.

They should use websecure entrypoint like this:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: example-com-tls
spec:
  entryPoints:
    - websecure
  routes:
  - match: Host(`test.example.com`)
    kind: Rule
    services:
    - name: XXXX
      port: 80
```

# Add custom (internal) services

In some cases you might want to have more than one Traefik service within your cluster,
e.g. a default (external) one and a service that is only exposed internally to pods within your cluster.

The `service.additionalServices` allows you to add an arbitrary amount of services,
provided as a name to service details mapping; for example you can use the following values:

```yaml
service:
  additionalServices:
    internal:
      type: ClusterIP
      labels:
        traefik-service-label: internal
```

Ports can then be exposed on this service by using the port name to boolean mapping `expose` on the respective port;
e.g. to expose the `traefik` API port on your internal service so pods within your cluster can use it, you can do:

```yaml
ports:
  traefik:
    expose:
      # Sensitive data should not be exposed on the internet
      # => Keep this disabled !
      default: false
      internal: true
```

This will then provide an additional Service manifest, looking like this:

```yaml
---
# Source: traefik/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik-internal
  namespace: traefik
[...]
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: traefik
    app.kubernetes.io/instance: traefik-traefik
  ports:
  - port: 8080
    name: traefik
    targetPort: traefik
    protocol: TCP
```

# Use this Chart as a dependency of your own chart


First, let's create a default Helm Chart, with Traefik as a dependency.
```bash
helm create foo
cd foo
echo "
dependencies:
  - name: traefik
    version: "24.0.0"
    repository: "https://traefik.github.io/charts"
" >> Chart.yaml
```

Second, let's tune some values like enabling HPA:

```bash
cat <<-EOF >> values.yaml
traefik:
  autoscaling:
    enabled: true
    maxReplicas: 3
EOF
```

Third, one can see if it works as expected:
```bash
helm dependency update
helm dependency build
helm template . | grep -A 14 -B 3 Horizontal
```

It should produce this output:

```yaml
---
# Source: foo/charts/traefik/templates/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: release-name-traefik
  namespace: flux-system
  labels:
    app.kubernetes.io/name: traefik
    app.kubernetes.io/instance: release-name-flux-system
    helm.sh/chart: traefik-24.0.0
    app.kubernetes.io/managed-by: Helm
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: release-name-traefik
  maxReplicas: 3
```

# Configure TLS

The [TLS options](https://doc.traefik.io/traefik/https/tls/#tls-options) allow one to configure some parameters of the TLS connection.

```yaml
tlsOptions:
  default:
    labels: {}
    sniStrict: true
  custom-options:
    labels: {}
    curvePreferences:
      - CurveP521
      - CurveP384
```

# Use latest build of Traefik v3 from master

An experimental build of Traefik Proxy is available on a specific community repository: `traefik/traefik`.

The tag does not follow semver, so it requires a _versionOverride_:

```yaml
image:
  repository: traefik/traefik
  tag: experimental-v3.4
versionOverride: v3.4
```

# Use Prometheus Operator

An optional support of this operator is included in this Chart. See documentation of this operator for more details.

It can be used with those _values_:

```yaml
metrics:
  prometheus:
    service:
      enabled: true
    disableAPICheck: false
    serviceMonitor:
      enabled: true
      metricRelabelings:
        - sourceLabels: [__name__]
          separator: ;
          regex: ^fluentd_output_status_buffer_(oldest|newest)_.+
          replacement: $1
          action: drop
      relabelings:
        - sourceLabels: [__meta_kubernetes_pod_node_name]
          separator: ;
          regex: ^(.*)$
          targetLabel: nodename
          replacement: $1
          action: replace
      jobLabel: traefik
      interval: 30s
      honorLabels: true
    headerLabels:
      user_id: X-User-Id
      tenant: X-Tenant
    prometheusRule:
      enabled: true
      rules:
        - alert: TraefikDown
          expr: up{job="traefik"} == 0
          for: 5m
          labels:
            context: traefik
            severity: warning
          annotations:
            summary: "Traefik Down"
            description: "{{ $labels.pod }} on {{ $labels.nodename }} is down"
```

# Use kubernetes Gateway API

One can use the new stable kubernetes gateway API provider setting the following _values_:

```yaml
providers:
  kubernetesGateway:
    enabled: true
```

<details>

<summary>With those values, a whoami service can be exposed with a HTTPRoute</summary>

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  replicas: 2
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami

---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  selector:
    app: whoami
  ports:
    - protocol: TCP
      port: 80

---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami
spec:
  parentRefs:
    - name: traefik-gateway
  hostnames:
    - whoami.docker.localhost
  rules:
    - matches:
        - path:
            type: Exact
            value: /

      backendRefs:
        - name: whoami
          port: 80
          weight: 1
```

Once it's applied, whoami should be accessible on http://whoami.docker.localhost/

</details>

:information_source: In this example, `Deployment` and `HTTPRoute` should be deployed in the same namespace as the Traefik Gateway: Chart namespace.

# Use Kubernetes Gateway API with cert-manager

One can use the new stable kubernetes gateway API provider with automatic TLS certificates delivery (with cert-manager) setting the following _values_:

```yaml
providers:
  kubernetesGateway:
    enabled: true
gateway:
  enabled: true
  annotations:
    cert-manager.io/issuer: selfsigned-issuer
  listeners:
    websecure:
      hostname: whoami.docker.localhost
      port: 8443
      protocol: HTTPS
      certificateRefs:
        - name: whoami-tls
```

Install cert-manager:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install \
cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.15.1 \
--set crds.enabled=true \
--set "extraArgs={--enable-gateway-api}"
```

<details>

<summary>With those values, a whoami service can be exposed with HTTPRoute on both HTTP and HTTPS</summary>

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  replicas: 2
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami

---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  selector:
    app: whoami
  ports:
    - protocol: TCP
      port: 80

---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami
spec:
  parentRefs:
    - name: traefik-gateway
  hostnames:
    - whoami.docker.localhost
  rules:
    - matches:
        - path:
            type: Exact
            value: /

      backendRefs:
        - name: whoami
          port: 80
          weight: 1

---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

Once it's applied, whoami should be accessible on https://whoami.docker.localhost/

</details>

# Use templating for additionalVolumeMounts

This example demonstrates how to use templating for the `additionalVolumeMounts` configuration to dynamically set the `subPath` parameter based on a variable.

```yaml
additionalVolumeMounts:
  - name: plugin-volume
    mountPath: /plugins
    subPath: "{{ .Values.pluginVersion }}"
```

In your `values.yaml` file, you can specify the `pluginVersion` variable:

```yaml
pluginVersion: "v1.2.3"
```

This configuration will mount the `plugin-volume` at `/plugins` with the `subPath` set to `v1.2.3`.

# Use a custom certificate for Traefik Hub webhooks

Some CD tools may regenerate Traefik Hub mutating webhooks continuously, when using helm template.
This example demonstrates how to generate and use a custom certificate for Hub admission webhooks.

First, generate a self-signed certificate:

```bash
# this generates a self-signed certificate with a 2048 bits key, valid for 10 years, on admission.traefik.svc DNS name
openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout /tmp/hub.key -out /tmp/hub.crt \
            -subj "/CN=admission.traefik.svc" -addext "subjectAltName=DNS:admission.traefik.svc"
cat /tmp/hub.crt | base64 -w0 > /tmp/hub.crt.b64
cat /tmp/hub.key | base64 -w0 > /tmp/hub.key.b64
```

Now, it can be set in the `values.yaml`:

```yaml
hub:
  apimanagement:
    admission:
      customWebhookCertificate:
        tls.crt: xxxx # content of /tmp/hub.crt.b64
        tls.key: xxxx # content of /tmp/hub.key.b64
```

> [!TIP]
> When using the CLI, those parameters need to be escaped like this:
>```bash 
> --set 'hub.apimanagement.admission.customWebhookCertificate.tls\.crt'=$(cat /tmp/hub.crt.b64)
> --set 'hub.apimanagement.admission.customWebhookCertificate.tls\.key'=$(cat /tmp/hub.key.b64)
>```
# Mount datadog DSD socket directly into traefik container (i.e. no more socat sidecar)

This example demonstrates how to directly mount datadog apm socket into traefik container, thus avoiding the need of socat sidecar container.

```yaml
metrics:
  datadog:
    address: unix:///var/run/datadog/dsd.socket # https://doc.traefik.io/traefik/observability/metrics/datadog/#address
additionalVolumeMounts:
  - name: ddsocketdir
    mountPath: /var/run/datadog
    readOnly: false
deployment:
  additionalVolumes:
    - hostPath:
        path: /var/run/datadog/
      name: ddsocketdir
```


# Use Traefik Hub AI Gateway

This example demonstrates how to enable AI Gateway in Traefik Hub and set a maxRequestBodySize of 10 MiB.

```yaml
hub:
  token: # <=== Set your token here
  aigateway:
    enabled: true
    maxRequestBodySize: 10485760 # optional, default to 1MiB
```
Traefik & Kubernetes
The Kubernetes Ingress Controller.

The Traefik Kubernetes Ingress provider is a Kubernetes Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification.

Requirements
Traefik follows the Kubernetes support policy, and supports at least the latest three minor versions of Kubernetes. General functionality cannot be guaranteed for older versions.

Routing Configuration
See the dedicated section in routing.

Enabling and Using the Provider
You can enable the provider in the static configuration:


File (YAML)

providers:
  kubernetesIngress: {}

File (TOML)

CLI
The provider then watches for incoming ingresses events, such as the example below, and derives the corresponding dynamic configuration from it, which in turn creates the resulting routers, services, handlers, etc.


Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foo
  namespace: production

spec:
  rules:
    - host: example.net
      http:
        paths:
          - path: /bar
            pathType: Exact
            backend:
              service:
                name:  service1
                port:
                  number: 80
          - path: /foo
            pathType: Exact
            backend:
              service:
                name:  service1
                port:
                  number: 80
LetsEncrypt Support with the Ingress Provider
By design, Traefik is a stateless application, meaning that it only derives its configuration from the environment it runs in, without additional configuration. For this reason, users can run multiple instances of Traefik at the same time to achieve HA, as is a common pattern in the kubernetes ecosystem.

When using a single instance of Traefik Proxy with Let's Encrypt, you should encounter no issues. However, this could be a single point of failure. Unfortunately, it is not possible to run multiple instances of Traefik 2.0 with Let's Encrypt enabled, because there is no way to ensure that the correct instance of Traefik receives the challenge request, and subsequent responses. Early versions (v1.x) of Traefik used a KV store to attempt to achieve this, but due to sub-optimal performance that feature was dropped in 2.0.

If you need Let's Encrypt with high availability in a Kubernetes environment, we recommend using Traefik Enterprise which includes distributed Let's Encrypt as a supported feature.

If you want to keep using Traefik Proxy, LetsEncrypt HA can be achieved by using a Certificate Controller such as Cert-Manager. When using Cert-Manager to manage certificates, it creates secrets in your namespaces that can be referenced as TLS secrets in your ingress objects.

Provider Configuration
endpoint
Optional, Default=""

The Kubernetes server endpoint URL.

When deployed into Kubernetes, Traefik reads the environment variables KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT or KUBECONFIG to construct the endpoint.

The access token is looked up in /var/run/secrets/kubernetes.io/serviceaccount/token and the SSL CA certificate in /var/run/secrets/kubernetes.io/serviceaccount/ca.crt. Both are mounted automatically when deployed inside Kubernetes.

The endpoint may be specified to override the environment variable values inside a cluster.

When the environment variables are not found, Traefik tries to connect to the Kubernetes API server with an external-cluster client. In this case, the endpoint is required. Specifically, it may be set to the URL used by kubectl proxy to connect to a Kubernetes cluster using the granted authentication and authorization of the associated kubeconfig.


File (YAML)

providers:
  kubernetesIngress:
    endpoint: "http://localhost:8080"
    # ...

File (TOML)

CLI
token
Optional, Default=""

Bearer token used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesIngress:
    token: "mytoken"
    # ...

File (TOML)

CLI
certAuthFilePath
Optional, Default=""

Path to the certificate authority file. Used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesIngress:
    certAuthFilePath: "/my/ca.crt"
    # ...

File (TOML)

CLI
namespaces
Optional, Default: []

Array of namespaces to watch. If left empty, Traefik watches all namespaces.


File (YAML)

providers:
  kubernetesIngress:
    namespaces:
      - "default"
      - "production"
    # ...

File (TOML)

CLI
labelSelector
Optional, Default: ""

A label selector can be defined to filter on specific Ingress objects only. If left empty, Traefik processes all Ingress objects in the configured namespaces.

See label-selectors for details.


File (YAML)

providers:
  kubernetesIngress:
    labelSelector: "app=traefik"
    # ...

File (TOML)

CLI
ingressClass
Optional, Default: ""

Value of kubernetes.io/ingress.class annotation that identifies Ingress objects to be processed.

If the parameter is set, only Ingresses containing an annotation with the same value are processed. Otherwise, Ingresses missing the annotation, having an empty value, or the value traefik are processed.

Example

File (YAML)

providers:
  kubernetesIngress:
    ingressClass: "traefik-internal"
    # ...

File (TOML)

CLI
disableIngressClassLookup
Optional, Default: false

Deprecated
If the parameter is set to true, Traefik will not discover IngressClasses in the cluster. By doing so, it alleviates the requirement of giving Traefik the rights to look IngressClasses up. Furthermore, when this option is set to true, Traefik is not able to handle Ingresses with IngressClass references, therefore such Ingresses will be ignored. Please note that annotations are not affected by this option.


File (YAML)

providers:
  kubernetesIngress:
    disableIngressClassLookup: true
    # ...

File (TOML)

CLI
disableClusterScopeResources
Optional, Default: false

When this parameter is set to true, Traefik will not discover cluster scope resources (IngressClass and Nodes). By doing so, it alleviates the requirement of giving Traefik the rights to look up for cluster resources. Furthermore, Traefik will not handle Ingresses with IngressClass references, therefore such Ingresses will be ignored (please note that annotations are not affected by this option). This will also prevent from using the NodePortLB options on services.


File (YAML)

providers:
  kubernetesIngress:
    disableClusterScopeResources: true
    # ...

File (TOML)

CLI
ingressEndpoint
hostname
Optional, Default: ""

Hostname used for Kubernetes Ingress endpoints.


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      hostname: "example.net"
    # ...

File (TOML)

CLI
ip
Optional, Default: ""

This IP will get copied to Ingress status.loadbalancer.ip, and currently only supports one IP value (IPv4 or IPv6).


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      ip: "1.2.3.4"
    # ...

File (TOML)

CLI
publishedService
Optional, Default: ""

Format: namespace/servicename.

The Kubernetes service to copy status from, depending on the service type:

ClusterIP: The ExternalIPs of the service will be propagated to the ingress status.
NodePort: The ExternalIP addresses of the nodes in the cluster will be propagated to the ingress status.
LoadBalancer: The IPs from the service's loadBalancer.status field (which contains the endpoints provided by the load balancer) will be propagated to the ingress status.
When using third-party tools such as External-DNS, this option enables the copying of external service IPs to the ingress resources.


File (YAML)

providers:
  kubernetesIngress:
    ingressEndpoint:
      publishedService: "namespace/foo-service"
    # ...

File (TOML)

CLI
throttleDuration
Optional, Default: 0

The throttleDuration option defines how often the provider is allowed to handle events from Kubernetes. This prevents a Kubernetes cluster that updates many times per second from continuously changing your Traefik configuration.

If left empty, the provider does not apply any throttling and does not drop any Kubernetes events.

The value of throttleDuration should be provided in seconds or as a valid duration format, see time.ParseDuration.


File (YAML)

providers:
  kubernetesIngress:
    throttleDuration: "10s"
    # ...

File (TOML)

CLI
allowEmptyServices
Optional, Default: false

If the parameter is set to true, it allows the creation of an empty servers load balancer if the targeted Kubernetes service has no endpoints available. This results in 503 HTTP responses instead of 404 ones.


File (YAML)

providers:
  kubernetesIngress:
    allowEmptyServices: true
    # ...

File (TOML)

CLI
allowExternalNameServices
Optional, Default: false

If the parameter is set to true, Ingresses are able to reference ExternalName services.


File (YAML)

providers:
  kubernetesIngress:
    allowExternalNameServices: true
    # ...

File (TOML)

CLI
nativeLBByDefault
Optional, Default: false

Defines whether to use Native Kubernetes load-balancing mode by default. For more information, please check out the traefik.ingress.kubernetes.io/service.nativelb service annotation documentation.


File (YAML)

providers:
  kubernetesIngress:
    nativeLBByDefault: true
    # ...

File (TOML)

CLI
Further
To learn more about the various aspects of the Ingress specification that Traefik supports, many examples of Ingresses definitions are located in the test examples of the Traefik repository.

Traefik & Kubernetes with Gateway API
The Kubernetes Gateway provider is a Traefik implementation of the Gateway API specification from the Kubernetes Special Interest Groups (SIGs).

This provider supports Standard version v1.2.1 of the Gateway API specification.

It fully supports all HTTP core and some extended features, as well as the TCPRoute and TLSRoute resources from the Experimental channel.

For more details, check out the conformance report.

Requirements
Traefik follows the Kubernetes support policy, and supports at least the latest three minor versions of Kubernetes. General functionality cannot be guaranteed for older versions.

Helm Chart

When using the Traefik Helm Chart, the CRDs (Custom Resource Definitions) and RBAC (Role-Based Access Control) are automatically managed for you. The only remaining task is to enable the kubernetesGateway in the chart values.

Install/update the Kubernetes Gateway API CRDs.


# Install Gateway API CRDs from the Standard channel.
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
Install the additional Traefik RBAC required for Gateway API.


# Install Traefik RBACs.
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.4/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml
Deploy Traefik and enable the kubernetesGateway provider in the static configuration as detailed below:


File (YAML)

providers:
  kubernetesGateway: {}

File (TOML)

CLI
Routing Configuration
When using the Kubernetes Gateway API provider, Traefik uses the Gateway API CRDs to retrieve its routing configuration. Check out the Gateway API concepts documentation, and the dedicated routing section in the Traefik documentation.

Provider Configuration
endpoint
Optional, Default=""

The Kubernetes server endpoint URL.

When deployed into Kubernetes, Traefik reads the environment variables KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT or KUBECONFIG to construct the endpoint.

The access token is looked up in /var/run/secrets/kubernetes.io/serviceaccount/token and the SSL CA certificate in /var/run/secrets/kubernetes.io/serviceaccount/ca.crt. Both are mounted automatically when deployed inside Kubernetes.

The endpoint may be specified to override the environment variable values inside a cluster.

When the environment variables are not found, Traefik tries to connect to the Kubernetes API server with an external-cluster client. In this case, the endpoint is required. Specifically, it may be set to the URL used by kubectl proxy to connect to a Kubernetes cluster using the granted authentication and authorization of the associated kubeconfig.


File (YAML)

providers:
  kubernetesGateway:
    endpoint: "http://localhost:8080"
    # ...

File (TOML)

CLI
token
Optional, Default=""

Bearer token used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesGateway:
    token: "mytoken"
    # ...

File (TOML)

CLI
certAuthFilePath
Optional, Default=""

Path to the certificate authority file. Used for the Kubernetes client configuration.


File (YAML)

providers:
  kubernetesGateway:
    certAuthFilePath: "/my/ca.crt"
    # ...

File (TOML)

CLI
namespaces
Optional, Default: []

Array of namespaces to watch. If left empty, Traefik watches all namespaces.


File (YAML)

providers:
  kubernetesGateway:
    namespaces:
    - "default"
    - "production"
    # ...

File (TOML)

CLI
statusAddress
ip
Optional, Default: ""

This IP will get copied to the Gateway status.addresses, and currently only supports one IP value (IPv4 or IPv6).


File (YAML)

providers:
  kubernetesGateway:
    statusAddress:
      ip: "1.2.3.4"
    # ...

File (TOML)

CLI
hostname
Optional, Default: ""

This Hostname will get copied to the Gateway status.addresses.


File (YAML)

providers:
  kubernetesGateway:
    statusAddress:
      hostname: "example.net"
    # ...

File (TOML)

CLI
service
Optional

The Kubernetes service to copy status addresses from. When using third parties tools like External-DNS, this option can be used to copy the service loadbalancer.status (containing the service's endpoints IPs) to the gateways.


File (YAML)

providers:
  kubernetesGateway:
    statusAddress:
      service:
        namespace: default
        name: foo
    # ...

File (TOML)

CLI
experimentalChannel
Optional, Default: false

Toggles support for the Experimental Channel resources (Gateway API release channels documentation). This option currently enables support for TCPRoute and TLSRoute.


File (YAML)

providers:
  kubernetesGateway:
    experimentalChannel: true

File (TOML)

CLI
Experimental Channel

When enabling experimental channel resources support, the experimental CRDs (Custom Resource Definitions) needs to be deployed too.


# Install Gateway API CRDs from the Experimental channel.
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml
labelselector
Optional, Default: ""

A label selector can be defined to filter on specific GatewayClass objects only. If left empty, Traefik processes all GatewayClass objects in the configured namespaces.

See label-selectors for details.


File (YAML)

providers:
  kubernetesGateway:
    labelselector: "app=traefik"
    # ...

File (TOML)

CLI
nativeLBByDefault
Optional, Default: false

Defines whether to use Native Kubernetes load-balancing mode by default. For more information, please check out the traefik.io/service.nativelb service annotation documentation.


File (YAML)

providers:
  kubernetesGateway:
    nativeLBByDefault: true
    # ...

File (TOML)

CLI
throttleDuration
Optional, Default: 0

The throttleDuration option defines how often the provider is allowed to handle events from Kubernetes. This prevents a Kubernetes cluster that updates many times per second from continuously changing your Traefik configuration.

If left empty, the provider does not apply any throttling and does not drop any Kubernetes events.

The value of throttleDuration should be provided in seconds or as a valid duration format, see time.ParseDuration.


File (YAML)

providers:
  kubernetesGateway:
    throttleDuration: "10s"
    # ...

DigestAuth
DigestAuth

The DigestAuth middleware grants access to services to authorized users only.

Configuration Examples

Structured (YAML)

Structured (TOML)

Labels

Tags

Kubernetes

# Declaring the user list
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: test-auth
spec:
  digestAuth:
    secret: userssecret
Configuration Options
Field	Description	Default	Required
users	Array of authorized users. Each user must be declared using the name:realm:encoded-password format.
The option users supports Kubernetes secrets.
(More information here)	[]	No
usersFile	Path to an external file that contains the authorized users for the middleware.
The file content is a list of name:realm:encoded-password. (More information here)	""	No
realm	Allow customizing the realm for the authentication.	"traefik"	No
headerField	Allow defining a header field to store the authenticated user.	""	No
removeHeader	Allow removing the authorization header before forwarding the request to your service.	false	No
Passwords format
Passwords must be hashed using MD5, SHA1, or BCrypt. Use htpasswd to generate the passwords.

users & usersFile
If both users and usersFile are provided, they are merged. The contents of usersFile have precedence over the values in users.
Because referencing a file path isn’t feasible on Kubernetes, the users & usersFile field isn’t used in Kubernetes IngressRoute. Instead, use the secret field.
Kubernetes Secrets
On Kubernetes, you don’t use the users or usersFile fields. Instead, you reference a Kubernetes secret using the secret field in your Middleware resource. This secret can be one of two types:

kubernetes.io/basic-auth secret: This secret type contains two keys—username and password—but is generally suited for a smaller number of users. Please note that these keys are not hashed or encrypted in any way, and therefore is less secure than the other method.
Opaque secret with a users field: Here, the secret contains a single string field (often called users) where each line represents a user. This approach allows you to store multiple users in one secret.
