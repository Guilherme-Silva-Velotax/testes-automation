#!/usr/bin/env python3
"""
setup_pre_commit.py
Script para configurar o hook pre-commit automaticamente
Funciona em Windows, Linux e Mac
Aceita o path do projeto como argumento
"""

import os
import stat
import sys
from pathlib import Path

def detect_test_command(project_path):
    """Detecta qual comando de teste usar baseado nos arquivos do projeto"""
    project_path = Path(project_path)
    
    # Verifica se existe pytest
    if (project_path / "pytest.ini").exists() or \
       (project_path / "pyproject.toml").exists() or \
       (project_path / "setup.py").exists() or \
       (project_path / "tests").exists():
        # Verifica se existe pasta tests
        tests_dir = project_path / "tests"
        if tests_dir.exists() and tests_dir.is_dir():
            return "pytest tests -v"
        return "pytest -v"
    
    # Verifica se existe unittest
    if (project_path / "test").exists():
        return "python -m unittest discover -v"
    
    # Padrão: pytest
    return "pytest -v"

def detect_venv_path(project_path):
    """Detecta o caminho da venv no projeto"""
    project_path = Path(project_path)
    
    venv_paths = ["venv", ".venv"]
    for venv_name in venv_paths:
        venv_dir = project_path / venv_name
        if venv_dir.exists() and venv_dir.is_dir():
            return venv_name
    
    return None

def setup_pre_commit_hook(project_path=None):
    """Configura o hook pre-commit do Git"""
    
    # Se não foi fornecido path, usa o diretório atual
    if project_path is None:
        project_path = Path.cwd()
    else:
        project_path = Path(project_path).resolve()
    
    # Verifica se o path existe
    if not project_path.exists():
        print(f"Erro: O caminho '{project_path}' não existe!")
        return False
    
    if not project_path.is_dir():
        print(f"Erro: '{project_path}' não é um diretório!")
        return False
    
    print(f"Configurando hook pre-commit no projeto: {project_path}")
    
    # Verifica se é um repositório Git
    git_dir = project_path / ".git"
    if not git_dir.exists():
        print(f"Erro: '{project_path}' não é um repositório Git!")
        print("Certifique-se de que o diretório contém uma pasta .git")
        return False
    
    # Detecta comando de teste
    test_command = detect_test_command(project_path)
    venv_name = detect_venv_path(project_path)
    
    print(f"Comando de teste detectado: {test_command}")
    if venv_name:
        print(f"Venv detectada: {venv_name}")
    
    # Define o caminho do hook
    hook_dir = project_path / ".git/hooks"
    hook_path = hook_dir / "pre-commit"
    
    # Cria o diretório se não existir
    hook_dir.mkdir(parents=True, exist_ok=True)
    
    # Conteúdo do hook
    venv_activation = ""
    if venv_name:
        venv_activation = f"""# Ativa a venv se existir
if [ -d "{venv_name}" ]; then
    source {venv_name}/bin/activate
fi
"""
    
    hook_content = f"""#!/bin/bash

# Pre-commit hook para rodar testes automaticamente antes do commit

echo "Rodando testes antes do commit..."

# Muda para o diretório do projeto
cd "{project_path}"

{venv_activation}
# Roda os testes
{test_command}

# Verifica o código de saída dos testes
if [ $? -ne 0 ]; then
    echo ""
    echo "Testes falharam! Commit cancelado."
    echo "Corrija os testes antes de fazer commit."
    exit 1
fi

echo ""
echo "Todos os testes passaram!"
exit 0
"""
    
    # Escreve o arquivo
    hook_path.write_text(hook_content, encoding='utf-8')
    
    # Torna executável (Linux/Mac)
    if os.name != 'nt':  # Não é Windows
        os.chmod(hook_path, os.stat(hook_path).st_mode | stat.S_IEXEC)
    
    print("Hook pre-commit configurado com sucesso!")
    print(f"Localização: {hook_path.absolute()}")
    print("\nPara testar, faça um commit e veja os testes rodarem automaticamente!")
    print("Exemplo: git commit -m 'test: verificar hook'")
    return True

if __name__ == "__main__":
    # Aceita path como argumento
    project_path = None
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
    
    setup_pre_commit_hook(project_path)