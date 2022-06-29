## Создание инфраструктуры для кластера Kubernetes в Yandex Cloud с помощью Terraform.

Конфигурация - [main.tf](main.tf).

Для выполнения задачи в качестве backend был выбран Terraform Cloud. Workspace подключен к данному репозиторию. После каждого "git push" происходит "terraform plan", "apply" запускается вручную. Предварительно в Yandex Cloud были созданы отдельная директория для проекта, сервисный аккаунт для работы с данной директорией, а также авторизованный ключ для работы Тerraform от имени сервисного аккаунта. Ключ экспортирован в файл key.json и содержимое указано в переменной "YC_SERVICE_ACCOUNT_KEY_FILE". Также в Terraform Cloud указаны переменные "CLOUD_ID" и "FOLDER_ID".

![inst](inst.jpg)

![lb](lb.jpg)