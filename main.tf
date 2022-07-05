provider "yandex" {
    service_account_key_file = var.YC_SERVICE_ACCOUNT_KEY_FILE
    cloud_id  = var.CLOUD_ID
    folder_id = var.FOLDER_ID
}

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

# compute instances #
 resource "yandex_compute_instance" "vm" {
    for_each = yandex_vpc_subnet.subnet
    name     = each.key
    zone     = each.value.zone
    allow_stopping_for_update = true
    network_interface {
        subnet_id = each.value.id
        nat       = true
    }
    resources {
        cores         = 2
        memory        = 4
        core_fraction = 100
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

# target group #
resource "yandex_lb_target_group" "tg-1" {
    name = "app-tg"
    target {
        subnet_id = "${yandex_compute_instance.vm["cp"].network_interface.0.subnet_id}"    
        address   = "${yandex_compute_instance.vm["cp"].network_interface.0.ip_address}" 
    }
     target {
        subnet_id = "${yandex_compute_instance.vm["node1"].network_interface.0.subnet_id}"    
        address   = "${yandex_compute_instance.vm["node1"].network_interface.0.ip_address}"    
    }
     target {
        subnet_id = "${yandex_compute_instance.vm["node2"].network_interface.0.subnet_id}"  
        address   = "${yandex_compute_instance.vm["node2"].network_interface.0.ip_address}"    
    }
}

# balancer #
resource "yandex_lb_network_load_balancer" "lb-1" {
    name = "app-lb"
    listener {
        name = "app-listener"
        port = 80
        target_port = 30003
        external_address_spec {
            ip_version = "ipv4"
        }
    }    
    listener {
        name = "grafana-listener"
        port = 8080
        target_port = 30902
        external_address_spec {
            ip_version = "ipv4"
        }
    }
    attached_target_group {
        target_group_id = "${yandex_lb_target_group.tg-1.id}"
        healthcheck {
            name = "app_check"
            http_options {
                port = 30003
            }
        }
    }
}