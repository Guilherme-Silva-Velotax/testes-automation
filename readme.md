# Setup Pre-Commit Hook

Scripts automatizados para configurar o hook pre-commit que roda testes automaticamente antes de cada commit.

## Como Usar

Os scripts aceitam o path do projeto como argumento. Se não fornecido, usam o diretório atual.

### Windows (PowerShell)
```powershell
# Configurar no projeto atual
.\setup-pre-commit.ps1

# Configurar em outro projeto
.\setup-pre-commit.ps1 C:\caminho\do\projeto
```

### Linux/Mac/Git Bash
```bash
# Dar permissão de execução (apenas na primeira vez)
chmod +x setup-pre-commit.sh

# Configurar no projeto atual
./setup-pre-commit.sh

# Configurar em outro projeto
./setup-pre-commit.sh /caminho/do/projeto
```

### Python (Qualquer plataforma)
```bash
# Configurar no projeto atual
python setup_pre_commit.py

# Configurar em outro projeto
python setup_pre_commit.py /caminho/do/projeto
```

## O que faz?

Após executar um dos scripts acima, toda vez que você fizer um `git commit`, os testes serão executados automaticamente:

- Se os testes passarem → commit é realizado normalmente
- Se os testes falharem → commit é cancelado

## Detecção Automática

Os scripts detectam automaticamente:

- **Comando de teste**: Procura por `pytest` ou `unittest` baseado na estrutura do projeto
  - Se existe pasta `tests/` → usa `pytest tests -v`
  - Se existe pasta `test/` → usa `python -m unittest discover -v`
  - Caso contrário → usa `pytest -v`

- **Virtual Environment**: Procura por venv nas seguintes pastas (nessa ordem):
  - `venv`
  - `.venv`
  - `env`
  - `.env`

## Desabilitar Temporariamente

Se precisar fazer um commit sem rodar os testes:

```bash
git commit --no-verify -m "sua mensagem"
```

## Personalização

Para modificar quais testes são executados, edite o arquivo `.git/hooks/pre-commit` após a configuração.
