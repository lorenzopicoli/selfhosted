terraform {
  backend "pg" {
    conn_str    = "postgres://opentofu-pg@192.168.40.26:5432/opentofu-pg?sslmode=disable"
    schema_name = "selfhosted"
  }
}
