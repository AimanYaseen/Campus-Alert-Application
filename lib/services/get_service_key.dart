import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // JSON credentials for the service account
    final serviceAccountJson = '''{
      "type": "service_account",
      "project_id": "collegealert-b24ce",
      "private_key_id": "833aee9b3206f09151fed0d743ea841bf8e98b61",
      "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDLajxKnMEpwf7a\\ndEe9z2y5HjsjqJDd0AXp8ACqfh7GckiUavnglcCULlo40XjOsXWOBIgZB+30Tnq2\\n+I6LOz37mjsoAEFs8/RXC+sWMAgtZABQ0mle06r8qlPF3zZNu1PHG8PEyIr3V5RW\\nvUFgAK2j4cjlLNVcv+NM+0UpapBNYIA1vh2ihe1g98L+sztqW+9oUHoy0IeGxPHk\\nEglPydhyfwLqZBoTFQFZYf1zLXxDV6rLYjqXyUi2wzElL7lDx0cagiTPjtFCmv0Z\\npfUElq8EDZPcSs/xv448Vj5K/9vxjC2jnbw+9Cmzewws2B15YxtQSv9m5BlvE622\\nj744C8GnAgMBAAECggEAKWTihQp2MoG0U48zJDioNtmkjkKYzFKvSWZaNFe6+oY6\\nJ93HIMFIsb7nBEX4UBODyRU5/uICteMcjMxy8XlqSR+fJyo6JipU0DvwKJE4sMf3\\nWnsfDzmCw60DpDIislnLGCsZwRtQUDolySr1OUyaCU4CnERt3NR9tGYzslRprhz2\\nQXIYxOGW+pqmVFotwJVqkOKPW8sovpBMOCm83TKQhIoqGRpqdL5hCkbVKwD9RhVM\\nfUJwM/bfT/8uusbVRcBobPODsZJXSc+xmk9YpdGuXQVQ887nGvw0daow1tpNOsTu\\nVNKG8yjM2zZh3HWoRKBZJkRRhuv8poKigWuuJ36+SQKBgQD9/43OwGHz9go3Y5Au\\nektNd2hHkUGS++mjWh1Y0oEagjEmLvFXi+tr45xMvdzyWyYbPHiL0CX0jYa4Cxbx\\nDZsLanzmS8Vr6CNOzipBNHISXI1PJpw3XF0Sfe70ka2iQtEa82x1WUnW+8zbok3h\\n+n6IvVR3KaLIRRJESBv77DiBuQKBgQDNBKEAHYPFlhYdvajl+b7vFOzC+Vkym0mD\\nEWZQ+V/b1WXzKqM6K4u3DwV/Ob2tu+Eoxm/g99sCaQNfMs9KmFNBC7pUyhlUExbv\\n/b4eky58BxwvEvSYB22vWmvO9WjpqjxmfZ1+4IaXKw9E5qYg7Ho3BOrYmyFTkrr5\\nT1BIy5eOXwKBgBgZSREWu7Rz4aBDuAhQ3hgpfiFcLMaPVCmFgUdOIaWsOJGQ3qEZ\\ny2pfHBND6FSuRT1MTXumchNz4hZQJwsT6WP55IPNKJwGWGM/uE6bdT88vMOHvEac\\nYtBAVo2pzLmacVCHTAEOSa02Ese77HvGUn8Sx5LOxn0N4J/N36nVTb8xAoGALwcF\\ny1n51QP1dMMBkCc2le7t1FeQD1yxgyAloSNiyrFrnljEcl50wPvwHdvn14dGQa0r\\nEqaoFShzfo3QIONKDZycFED7iF6Mn2ZMCwVl30teOqoVcx4ZGeUa37FJbHgBPN1J\\nmEX2eYyGBx8FMn4sFpzJJgCHp3z76J4540jYLe8CgYAYlvFAAgXALM7DhrZFeiRE\\ndFKRD6n4B7VJ3pipZgTSC4EQd1hICWDoaEOfaVsok+fXRmiPpn0haXzaJEFe51yT\\nbwH/oOdAdkw0wTV3Ao1DtW5T3xqCUliCYRMUcl6k8FLDUmtgLN2+St7YKInyj4ze\\naucaMEFQdMpPOet+QZUM1w==\\n-----END PRIVATE KEY-----\\n",
      "client_email": "firebase-adminsdk-tddd9@collegealert-b24ce.iam.gserviceaccount.com",
      "client_id": "104411354759763862152",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-tddd9%40collegealert-b24ce.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }''';

    final credentials = ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

    final client = await clientViaServiceAccount(
      credentials,
      scopes,
    );

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
