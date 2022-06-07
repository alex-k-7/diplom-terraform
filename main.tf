provider "yandex" {
    token     = var.OA_TOKEN
    cloud_id  = var.CLOUD_ID
    folder_id = var.FOLDER_ID
}

# service account #
resource "yandex_iam_service_account" "sa-fm" {
    name        = "folder-manager"
    description = "service account to manage resources in netology-diplom folder"
}

resource "yandex_resourcemanager_folder_iam_member" "f-edit" {
    folder_id = var.FOLDER_ID
    role      = "editor"
    member    = "serviceAccount:${yandex_iam_service_account.sa-fm.id}"
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
*/
# virtual machines #
 resource "yandex_compute_instance" "vm" {
    for_each  = yandex_vpc_subnet.subnet
    #for_each = var.ZONE
    #zone = each.key
    name = "node-${each.key}"
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
        }
    }
    network_interface {
        subnet_id = each.value.id
        nat       = true
    }
    #metadata = {
    #    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    #}
} 
/*
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
        subnet_id = "e2lnvult7bk2kmov69fi"
    }
    #metadata = {
    #    serial-port-enable = 1
    #    user-data = "${file(".terraform/user-data.txt")}"
    #}
}
*/