# setup-pre-commit.ps1
# Script para configurar o hook pre-commit automaticamente
# Uso: .\setup-pre-commit.ps1 [caminho_do_projeto]

param(
    [string]$ProjectPath = $PWD.Path
)

Write-Host "Configurando hook pre-commit..." -ForegroundColor Cyan

# Resolve o path absoluto
$ProjectPath = (Resolve-Path -Path $ProjectPath -ErrorAction SilentlyContinue).Path
if (-not $ProjectPath) {
    Write-Host "Erro: O caminho '$ProjectPath' não existe!" -ForegroundColor Red
    exit 1
}

Write-Host "Projeto: $ProjectPath" -ForegroundColor Gray

# Verifica se é um repositório Git
$gitDir = Join-Path $ProjectPath ".git"
if (-not (Test-Path $gitDir)) {
    Write-Host "Erro: '$ProjectPath' não é um repositório Git!" -ForegroundColor Red
    Write-Host "Certifique-se de que o diretório contém uma pasta .git" -ForegroundColor Yellow
    exit 1
}

# Detecta venv
$venvName = $null
$venvPaths = @("venv", ".venv", "env", ".env")
foreach ($venv in $venvPaths) {
    $venvPath = Join-Path $ProjectPath $venv
    if (Test-Path $venvPath) {
        $venvName = $venv
        break
    }
}

# Cria pytest.ini se não existir
$pytestIniPath = Join-Path $ProjectPath "pytest.ini"
if (-not (Test-Path $pytestIniPath)) {
    $pytestIniContent = @"
[pytest]
pythonpath = .
"@
    $pytestIniContent | Out-File -FilePath $pytestIniPath -Encoding utf8
    Write-Host "Arquivo pytest.ini criado: $pytestIniPath" -ForegroundColor Gray
}

# Detecta comando de teste
$testCmd = "python -m pytest -v"
$testsDir = Join-Path $ProjectPath "tests"
$testDir = Join-Path $ProjectPath "test"

if (Test-Path $testsDir) {
    $testCmd = "python -m pytest tests -v"
} elseif (Test-Path $testDir) {
    $testCmd = "python -m unittest discover -v"
}

Write-Host "Comando de teste detectado: $testCmd" -ForegroundColor Gray
if ($venvName) {
    Write-Host "Venv detectada: $venvName" -ForegroundColor Gray
}

$hookPath = Join-Path $ProjectPath ".git\hooks\pre-commit"

# Cria o diretório se não existir
$hookDir = Split-Path -Parent $hookPath
if (-not (Test-Path $hookDir)) {
    New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
}

# Monta o conteúdo do hook
$venvActivation = ""
if ($venvName) {
    $venvActivation = @"
# Ativa a venv se existir
if [ -d "$venvName" ]; then
    source $venvName/bin/activate
fi
"@
}

# Converte o path do Windows para formato Unix (para o bash)
# Git Bash no Windows aceita paths no formato C:/Users/... ou /c/Users/...
$projectPathUnix = $ProjectPath -replace '\\', '/'
if ($projectPathUnix -match '^([A-Z]):') {
    $drive = $matches[1].ToLower()
    $projectPathUnix = $projectPathUnix -replace '^[A-Z]:', "/$drive"
}

$hookContent = @"
#!/bin/bash

# Pre-commit hook para rodar testes automaticamente antes do commit

echo "Rodando testes antes do commit..."

# Muda para o diretório do projeto
cd "$projectPathUnix"

$venvActivation
# Roda os testes
$testCmd

# Verifica o código de saída dos testes
if [ `$? -ne 0 ]; then
    echo ""
    echo "Testes falharam! Commit cancelado."
    echo "Corrija os testes antes de fazer commit."
    exit 1
fi

echo ""
echo "Todos os testes passaram!"
exit 0
"@

# Cria o arquivo do hook
$hookContent | Out-File -FilePath $hookPath -Encoding utf8 -NoNewline

Write-Host "Hook pre-commit configurado com sucesso!" -ForegroundColor Green
Write-Host "Localização: $hookPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Para testar, faça um commit e veja os testes rodarem automaticamente!" -ForegroundColor Yellow
Write-Host "Exemplo: git commit -m 'test: verificar hook'" -ForegroundColor Gray