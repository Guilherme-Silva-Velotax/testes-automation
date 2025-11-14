#!/bin/bash
# setup-pre-commit.sh
# Script para configurar o hook pre-commit automaticamente
# Uso: ./setup-pre-commit.sh [caminho_do_projeto]

# Define o path do projeto (usa argumento ou diretório atual)
PROJECT_PATH="${1:-$(pwd)}"
PROJECT_PATH=$(realpath "$PROJECT_PATH")

echo "Configurando hook pre-commit no projeto: $PROJECT_PATH"

# Verifica se o path existe
if [ ! -d "$PROJECT_PATH" ]; then
    echo "Erro: O caminho '$PROJECT_PATH' não existe!"
    exit 1
fi

# Verifica se é um repositório Git
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo "Erro: '$PROJECT_PATH' não é um repositório Git!"
    echo "Certifique-se de que o diretório contém uma pasta .git"
    exit 1
fi

# Detecta venv
VENV_NAME=""
if [ -d "$PROJECT_PATH/venv" ]; then
    VENV_NAME="venv"
elif [ -d "$PROJECT_PATH/.venv" ]; then
    VENV_NAME=".venv"
elif [ -d "$PROJECT_PATH/env" ]; then
    VENV_NAME="env"
fi

# Detecta comando de teste
TEST_CMD="pytest -v"
if [ -d "$PROJECT_PATH/tests" ]; then
    TEST_CMD="pytest tests -v"
elif [ -d "$PROJECT_PATH/test" ]; then
    TEST_CMD="python -m unittest discover -v"
fi

echo "Comando de teste detectado: $TEST_CMD"
if [ -n "$VENV_NAME" ]; then
    echo "Venv detectada: $VENV_NAME"
fi

HOOK_PATH="$PROJECT_PATH/.git/hooks/pre-commit"

# Cria o diretório se não existir
mkdir -p "$(dirname "$HOOK_PATH")"

# Cria o hook com o path do projeto
cat > "$HOOK_PATH" << EOF
#!/bin/bash

# Pre-commit hook para rodar testes automaticamente antes do commit

echo "Rodando testes antes do commit..."

# Muda para o diretório do projeto
cd "$PROJECT_PATH"

$(if [ -n "$VENV_NAME" ]; then
    echo "# Ativa a venv se existir"
    echo "if [ -d \"$VENV_NAME\" ]; then"
    echo "    source $VENV_NAME/bin/activate"
    echo "fi"
fi)

# Roda os testes
$TEST_CMD

# Verifica o código de saída dos testes
if [ \$? -ne 0 ]; then
    echo ""
    echo "Testes falharam! Commit cancelado."
    echo "Corrija os testes antes de fazer commit."
    exit 1
fi

echo ""
echo "Todos os testes passaram!"
exit 0
EOF

# Torna o arquivo executável
chmod +x "$HOOK_PATH"

echo "Hook pre-commit configurado com sucesso!"
echo "Localização: $HOOK_PATH"
echo ""
echo "Para testar, faça um commit e veja os testes rodarem automaticamente!"
echo "Exemplo: git commit -m 'test: verificar hook'"