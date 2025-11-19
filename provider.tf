terraform {
  required_providers {
    cloudstack = {
      source  = "cloudstack/cloudstack"
      version = "0.6.0"
    }
  }
}


provider "cloudstack" {
  api_url    = "http://192.168.68.103:8080/client/api"
  api_key    = "U_peugiJJz7IOlsOjHIBH_FlcbCp-e1shduW2uyMqjyDe4u0dawXlQXsUxfmJgMFkZ_33EjGuE4Fhua_4n1XRw"
  secret_key = "_GYTwOvQc5qzXlUudgg0GNeqpLzkQhNBfspatkgacIsBusEQH7VMFBEUPxfHeDHUQE9i_8qpMAu9s0VrcU3vLg"
}
