# Workload Identity Federation

This repository provides a comprehensive guide and sample code to establish Workload Identity Federation (WIF) in Google Cloud Platform (GCP) for securely connecting external workloads (e.g., GitHub Actions workflows) to GCP resources

Workload Identity Federation (WIF) in Google Cloud Platform (GCP) is a security feature that allows your external workloads running outside of GCP to access GCP resources without needing to manage long-lived service account keys. It provides a more secure and manageable alternative to traditional service account key-based authentication.

You can find more details about enabling keyless authentication from GitHub Actions [here](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions).

Refer youtube Video for this project
 [![YouTube](https://img.shields.io/badge/YouTube-Video-red)](https://youtu.be/psm98noY-JM?si=Y8YI8p4-BbwcSYJC)

![image](https://github.com/vishal-bulbule/tf-gcp-wif-demo/assets/143475073/99126df6-bd66-4b10-a4f3-1fdc42670535)


Here's a breakdown of how WIF works:

1. **Workload Identity Pool:** You create a workload identity pool in your GCP project. This pool serves as a container for trusted external identities (e.g., GitHub Actions runner, CI/CD server).

2. **Workload Identity Provider:** You configure a workload identity provider within the pool. This provider specifies how external identities will be mapped to GCP identities. Common providers include GitHub, Azure Active Directory, and AWS IAM.

3. **External Workload Authentication:** When your external workload (e.g., GitHub Actions workflow) needs to access GCP resources, it authenticates with its own identity provider (e.g., GitHub).

4. **Token Exchange:** The external identity provider issues a short-lived token for the workload. This token is then exchanged with the GCP Security Token Service (STS) using the configured workload identity provider.

5. **Federated Token Issuance:** The GCP STS verifies the external token and, if valid, issues a temporary GCP access token with specific permissions granted to the workload identity pool's service account.

6. **GCP Resource Access:** The external workload uses the temporary GCP access token to access authorized GCP resources. This token has a limited lifespan and specific permissions, enhancing security.

**Benefits of Workload Identity Federation:**

* **Improved Security:** Eliminates the need to store and manage long-lived service account keys within your external workloads or repositories, reducing the risk of compromised credentials.
* **Automatic Key Rotation:** WIF leverages short-lived tokens that automatically expire, mitigating the need for manual key rotation.
* **Simplified Management:**  Focuses permission management on the service account associated with the workload identity pool within GCP.
* **Fine-grained Access Control:**  Allows you to grant specific IAM permissions to the service account, ensuring workloads only have the necessary access to GCP resources.

**Use Cases for WIF:**

* CI/CD pipelines running in external platforms like GitHub Actions or Jenkins that need to interact with GCP resources.
* Serverless functions or applications deployed outside GCP that require access to GCP services.
* Any external workload that needs secure and temporary access to GCP resources.

**In summary, Workload Identity Federation offers a secure and convenient way for your external workloads to interact with GCP resources without managing long-lived credentials. It simplifies access control and enhances security by leveraging short-lived tokens and granular permission management.**

I'd be glad to provide the steps for creating a Workload Identity Federation (WIF) setup in GCP and updating your code for WIF authentication in your GitHub Actions workflow:

**Prerequisites:**

* A Google Cloud Platform (GCP) project with the Cloud IAM API enabled (usually enabled by default).
* A GitHub repository where your workflow resides.

**Steps:**

1. **Create a Workload Identity Pool:**

   - Go to the GCP IAM & Admin console ([https://console.cloud.google.com/iam-admin/iam](https://console.cloud.google.com/iam-admin/iam)).
   - Navigate to the **Workload Identity Pools** section (might be under Security in newer consoles).
   - Click **Create pool**.
   - Provide a name for your pool (e.g., `github-actions-pool`).
   - Optionally, add a description.
   - Click **Create**.
  
  
     <img width="518" alt="image" src="https://github.com/vishal-bulbule/tf-gcp-wif-demo/assets/143475073/e11cd2a6-8ee4-4602-ba99-e453f07efa69">


2. **Create a Workload Identity Provider:**

   - In the Workload Identity Pools section, select the pool you just created (e.g., `github-actions-pool`).
   - Click **Add provider**.
   - Choose the provider type that matches your external identity source (e.g., GitHub, Azure Active Directory, AWS IAM). Here, we'll assume GitHub.
   - Provide a name for the provider (e.g., `github-provider`).
   - Optionally, configure additional provider-specific settings if applicable (refer to the official documentation for details).
     - For GitHub, you might need to provide the GitHub organization or enterprise ID.
   - Click **Save**.

3. **Create a Service Account:**

   - Go to the **Service Accounts** section (might be under IAM & Admin in newer consoles).
   - Click **Create account**.
   - Provide a name for the service account (e.g., `github-actions-sa`).
   - Optionally, add a description.
   - Click **Create**.

4. **Add IAM Binding:**
   ```BASH
   gcloud iam service-accounts add-iam-policy-binding "github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
   --project="${PROJECT_ID}" \
   --role="roles/iam.workloadIdentityUser" \
   --member="principalSet://iam.googleapis.com/projects/1234567890/locations/global/workloadIdentityPools/my-pool/attribute.repository/my-org/my-repo"
     ```

  <img width="962" alt="image" src="https://github.com/vishal-bulbule/tf-gcp-wif-demo/assets/143475073/371fdfc8-a20a-46b2-baac-4d19e1d8896d">


5. **Update Code for WIF (GitHub Actions):**

   - In your GitHub Actions workflow YAML file, locate the section responsible for authentication.
   - If you were previously using a service account key, remove the section related to it (e.g., `credentials_json`).
   - Uncomment the lines related to workload identity federation (assuming they were commented out):

     ```yaml
     - id: auth
       uses: google-github-actions/auth@v2.0.0  # Update to the latest version
       with:
         workload_identity_provider: 'projects/your-project-number/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider'
         service_account: 'github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com'
     ```

   - Replace the placeholders with your actual project Number, pool ID, provider ID, and service account details.



By following these steps, you'll have a WIF setup in GCP and your GitHub Actions workflow will be configured to leverage it for secure authentication. This eliminates the need to manage long-lived service account keys in your repository, improving security and reducing the risk of compromised credentials.

