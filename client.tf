resource "oci_core_instance" "client" {
  display_name        = "client-${count.index}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${var.availability_domain}"
  shape               = "${var.clients["shape"]}"
  subnet_id           = "${var.subnet_ocid}"
  source_details {
    source_id = "${var.images[var.region]}"
  	source_type = "image"
  }

  create_vnic_details {
        subnet_id = "${var.subnet_ocid}"
        hostname_label = "client-${count.index}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      "nodes=\"${var.nodes}\"",
      "test_name=\"${var.test_name}\"",
      "par=\"${var.par}\"",
      file("setup.sh"),
      file("test.sh")
    )))}"
  }
  count = "${var.clients["node_count"]}"
}

output "Client public IPs" { value = "${join(",", oci_core_instance.client.*.public_ip)}" }
output "Client private IPs" { value = "${join(",", oci_core_instance.client.*.private_ip)}" }
