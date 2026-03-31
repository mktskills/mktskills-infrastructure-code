##################################################
## DNS Zones — mktskills.ai
##################################################

module "dns_zone_mktskillsai" {
  source = "../../../modules/gcp_dns_zone"
  providers = {
    google = google
  }
  project_id        = local.project_id
  managed_zone_name = "${local.project_folder_code}-mktskillsai"
  dns_name          = "mktskills.ai."
  dns_records       = []
}

##################################################
## Google Workspace DNS Records
##################################################

resource "google_dns_record_set" "mx_root" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "mktskills.ai."
  type         = "MX"
  ttl          = 300
  rrdatas      = ["1 smtp.google.com."]
}

resource "google_dns_record_set" "txt_dkim" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "google._domainkey.mktskills.ai."
  type         = "TXT"
  ttl          = 300
  rrdatas = [
    "\"v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAj/fp1zBhP6FgbjEXMmRr1H9C6Un+xU9/T4p4JyJDrnzUNMkpd/UeLgJcXhG9xpv4VWVgbpSA3fVT1od4vPc7qTZLBefCj3N+Y2UDjZYLQQ1ybYOM2bfvhWkL67OpAdEVbKuNeoMserQQi6CPcHCvE+FWW6H6YY1PxE5KBMHQ6BpaJKL/BfaI9NSaLuJ46GuNELU\" \"YZyHeNDPrg9pd/WCGLHNPRzASjn/9Swrk0UQVleTN+2fLR4ZCvL1yxpcqu0CtMGmupNxi7uxTz7UT8YNC+nm1jGaWiW3sZv0G78CxG4G7/MYN7QNvWY+7E1M+Bb3jSULh3yVJncVLltDS6yKCAQIDAQAB\""
  ]
}

resource "google_dns_record_set" "txt_site_verification" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "mktskills.ai."
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"google-site-verification=DBh7R5LoeTSIc5CPMD7FDCjfHdmbO-uKFgdYpu9BJcY\""]
}

##################################################
## Resend DNS Records (platform transactional email)
## Sending domain: send.mktskills.ai
## Does not conflict with Google Workspace (root domain MX/SPF unchanged)
##################################################

# DKIM — value from Resend dashboard → Domains → mktskills.ai → DNS Records
resource "google_dns_record_set" "txt_resend_dkim" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "resend._domainkey.mktskills.ai."
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCz6lycj1JxhFmiaDyQPWVMbZZO0rqkVQYC5lnWFc/Rls2fJP7qNHdwth/SkFyW8bHyEYqyFzFNxQxR20H9cwN47ij5ws6DGdav7kpzEp0+4z6+3vlQdyxUtjnNcUFp9hzZ7heeMO5DoxsNceFe0ey1ZPaePJ4gzeYIPYemZB2JIQIDAQAB\""]
}

# MX for bounce/feedback processing (Amazon SES backend used by Resend)
resource "google_dns_record_set" "mx_resend_send" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "send.mktskills.ai."
  type         = "MX"
  ttl          = 300
  rrdatas      = ["10 feedback-smtp.us-east-1.amazonses.com."]
}

# SPF for send subdomain
resource "google_dns_record_set" "txt_resend_spf" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "send.mktskills.ai."
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"v=spf1 include:amazonses.com ~all\""]
}

# DMARC — root domain policy (p=none = monitor only, no enforcement)
resource "google_dns_record_set" "txt_dmarc" {
  provider     = google
  project      = local.project_id
  managed_zone = "dnszone-${local.project_folder_code}-mktskillsai"
  name         = "_dmarc.mktskills.ai."
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["\"v=DMARC1; p=none;\""]
}
