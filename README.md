# Python-flash-app-Docker
Aplicação Web Dockenizada, escrita em Python3 / Flask, utiliza Gunicorn como Web Server, CI-CD (Github Actions), Azure Web App, Azure Container Registry e IaC Terraform.

## ToDo:


* ~~Criar esteira ci-cd no github~~ - Feito
* ~~Criar Build (Docker)~~ - Feito
* ~~Criar Deploy (Azure Web App)~~ - Feito
* __Provisionar a Infra no Azure com Terraform__

## Workflow CI-CD (Github Actions)


```yaml
jobs:
  build:
    # Apenas executa build/deploy ao receber 
    # uma msg de commit que contenha. "[build]"
    if: "contains(github.event.head_commit.message, '[build]')"
    runs-on: ubuntu-latest

    steps:
        # Realiza checkout no repositorio remoto
      - uses: actions/checkout@v2

        # Cria uma imagem docker
      - name: Build the Docker image
        run: docker build . --file Dockerfile -t my-image-name:xwebapp -t xwebapp:${{ github.sha }}
        
        # Realiza login no Azure Container registry - ACR
      - name: ACR login azure
        uses: azure/docker-login@v1
        with:
          login-server: pythonapp10.azurecr.io
          username: ${{ env.REGISTRY_USERNAME }}
          password: ${{ env.REGISTRY_PASSWORD }}       
          
        # Renomeia a tag para o formato do ACR
      - run: docker tag xwebapp:${{ github.sha }} pythonapp10.azurecr.io/xwebapp:${{ github.sha }}
      
        # Envia a imagem para o ACR
      - run: docker push pythonapp10.azurecr.io/xwebapp:${{ github.sha }}

  # realiza o deploy no ambiente de produção          
  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'Production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
        # Realiza login no Azure Container registry - ACR
      - name: 'Login via Azure CLI'
        uses: azure/login@v1
        with:
          creds: ${{ env.AZURELOGIN }}
        
        # Parametriza as credencias de login do ACR nas conf da Web App
      - name: Set Web App ACR authentication
        uses: Azure/appservice-settings@v1
        with:
          app-name: 'xwebapp'
          app-settings-json: |
            [
                {
                    "name": "DOCKER_REGISTRY_SERVER_PASSWORD",
                    "value": "${{ env.REGISTRY_PASSWORD }}",
                    "slotSetting": false
                },
                {
                 "name": "DOCKER_REGISTRY_SERVER_URL",
                 "value": "pythonapp10.azurecr.io",
                 "slotSetting": false
                },
                {
                 "name": "DOCKER_REGISTRY_SERVER_USERNAME",
                 "value": "${{ env.REGISTRY_USERNAME  }}",
                 "slotSetting": false
                }
            ]

        # Executa o deploy da app utilizando como origem o ACR  
      - name: 'Deploy to Azure Web App'
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'xwebapp'
          images: 'pythonapp10.azurecr.io/xwebapp:${{ github.sha }}'
          
      - name: Azure logout
        run: |
          az logout


## Disponível em:

```python
https://xwebapp.azurewebsites.net/
```

## Algumas metricas da App  

![App Metric 1](https://github.com/jamylguimaraes/Python-flask-app-Docker/blob/main/screenshots/metrica_data_in_out.png?raw=true)

![App Metric 2](https://github.com/jamylguimaraes/Python-flask-app-Docker/blob/main/screenshots/metrica_response_request.png?raw=true)


## Stack Utilizada:
* __Python 3__
* __Flask__
* __Docker__
* __Gunicorn__
* __Github Actions__
* __Azure Web App__
* __Azure Container Registry__
* __Terraform__

