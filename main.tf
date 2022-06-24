provider "yandex" {
    service_account_key_file = var.YC_SERVICE_ACCOUNT_KEY_FILE
    cloud_id  = var.CLOUD_ID
    folder_id = var.FOLDER_ID
}

/*# service account #
resource "yandex_iam_service_account" "sa-fm" {
    name        = "folder-manager"
    description = "to manage resources in netology-diplom folder"
}

resource "yandex_resourcemanager_folder_iam_member" "f-edit" {
    folder_id = var.FOLDER_ID
    role      = "editor"
    member    = "serviceAccount:${yandex_iam_service_account.sa-fm.id}"
}
*/

# network #
resource "yandex_vpc_network" "net-1" {
    name = "net-1"
}

resource "yandex_vpc_subnet" "subnet" {
    for_each = var.VM
    zone           = each.value.zone
    v4_cidr_blocks = [each.value.cidr_block]
    network_id     = "${yandex_vpc_network.net-1.id}"
}

# virtual machines #
 resource "yandex_compute_instance" "vm" {
    for_each = yandex_vpc_subnet.subnet
    name     = each.key
    zone     = each.value.zone
    #service_account_id = "${yandex_iam_service_account.sa-fm.id}"
    network_interface {
        subnet_id = each.value.id
        nat       = true
    }
    scheduling_policy {
        preemptible = true
    }
    resources {
        cores         = 2
        memory        = 2
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = "fd86cpunl4kkspv0u25a"
            size     = 20
        }
    }
    metadata = {
        user-data = "${file("user-data.txt")}"
    }
}
/*
# target group #
resource "yandex_lb_target_group" "tg-1" {
    name = "app-tg"
    target {
        subnet_id = "${yandex_compute_instance.vm["ru-central1-a"].network_interface.0.subnet_id}"    
        address   = "${yandex_compute_instance.vm["ru-central1-a"].network_interface.0.ip_address}" 
    }
     target {
        subnet_id = "${yandex_compute_instance.vm["ru-central1-b"].network_interface.0.subnet_id}"    
        address   = "${yandex_compute_instance.vm["ru-central1-b"].network_interface.0.ip_address}"    
    }
     target {
        subnet_id = "${yandex_compute_instance.vm["ru-central1-c"].network_interface.0.subnet_id}"  
        address   = "${yandex_compute_instance.vm["ru-central1-c"].network_interface.0.ip_address}"    
    }

}

# balancer #
/*resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "app-lb"
  listener {
    name = "app-listener"
    port = 80
    target_port = 30003
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.tg-1.id}"
    healthcheck {
      name = "tcp"
      tcp_options {
        port = 30003
      }
    }
  }
}
*/