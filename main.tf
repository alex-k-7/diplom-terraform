provider "yandex" {
    token     = var.OA_TOKEN
    cloud_id  = var.CLOUD_ID
    folder_id = var.FOLDER_ID
}

# network #
resource "yandex_vpc_network" "net-1" {
    name = "net-1"
}

resource "yandex_vpc_subnet" "subnet" {
    for_each = var.ZONE
    zone           = each.key
    v4_cidr_blocks = [each.value]
    network_id     = "${yandex_vpc_network.net-1.id}"
}

/*
# nat-instance #
resource "yandex_compute_instance" "nat" {
    name = "nat-instance"
    scheduling_policy {
        preemptible = true
    }
    resources {
        cores  = 2
        memory = 1
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = "fd80mrhj8fl2oe87o4e1"
        }
    }
    network_interface {
        subnet_id  = "${yandex_vpc_subnet.netology-subnet-a.id}"
        ip_address = "192.168.10.254"
        nat        = true
    }
}
# virtual machines #
 resource "yandex_compute_instance" "vm1" {
    name = "public-vm"
    scheduling_policy {
        preemptible = true
    } 
    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = "fd86cpunl4kkspv0u25a"
        }
    }
    network_interface {
        subnet_id = "${yandex_vpc_subnet.netology-subnet-a.id}"
        nat       = true
    }
    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
} 

resource "yandex_compute_instance" "vm2" {
    name = "private-vm"
    scheduling_policy {
        preemptible = true
    }
    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = "fd86cpunl4kkspv0u25a"
        }
    }
    network_interface {
        subnet_id = "${yandex_vpc_subnet.netology-subnet-b.id}"
    }
    metadata = {
        serial-port-enable = 1
        user-data = "${file(".terraform/user-data.txt")}"
    }
}
*/