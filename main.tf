provider "yandex" {
    token     = var.OA_TOKEN
    cloud_id  = var.CLOUD_ID
    folder_id = var.FOLDER_ID
}

# service account #
resource "yandex_iam_service_account" "sa-fm" {
    name        = "folder-manager"
    description = "to manage resources in netology-diplom folder"
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

# virtual machines #
 resource "yandex_compute_instance" "vm" {
    for_each  = yandex_vpc_subnet.subnet
    zone = each.key
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
            size = 20
        }
    }
    network_interface {
        subnet_id = each.value.id
        nat       = true
    }
    metadata = {
        user-data = "${file("user-data.txt")}"
    }
    service_account_id = "${yandex_iam_service_account.sa-fm.id}"
}

# target group #
resource "yandex_lb_target_group" "balancer" {
    name = "app-balancer"
    target {
        subnet_id = "${yandex_vpc_subnet.subnet.0.id}"
        address = "${yandex_compute_instance.vm.0.network_interface.0.ip_address}"    
    }
     target {
        subnet_id = "${yandex_vpc_subnet.subnet.1.id}"
        address = "${yandex_compute_instance.vm.1.network_interface.0.ip_address}"    
    }
     target {
        subnet_id = "${yandex_vpc_subnet.subnet.2.id}"
        address = "${yandex_compute_instance.vm.2.network_interface.0.ip_address}"    
    }
}
# balancer #