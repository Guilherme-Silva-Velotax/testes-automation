# Setup Pre-Commit Hook

Executável automatizado para configurar o hook pre-commit que roda testes automaticamente antes de cada commit.

## Como Usar

### Windows

1. Baixe o arquivo `setup-pre-commit.exe`
2. Execute o arquivo (duplo clique)
3. Digite o caminho do projeto Git ou pressione Enter para usar o diretório atual
4. Pronto! O hook será configurado automaticamente

**Exemplo:**
```
C:\projetos\meu-projeto> setup-pre-commit.exe
```

O executável funciona de forma standalone - não precisa de nenhum outro arquivo ou dependência instalada.

## O que faz?

Após executar o `setup-pre-commit.exe`, toda vez que você fizer um `git commit`, os testes serão executados automaticamente:

- Se os testes passarem → commit é realizado normalmente
- Se os testes falharem → commit é cancelado

## Detecção Automática

O executável detecta automaticamente:

- **Comando de teste**: Procura por `pytest` ou `unittest` baseado na estrutura do projeto
  - Se existe pasta `tests/` → usa `python -m pytest tests -v`
  - Se existe pasta `test/` → usa `python -m unittest discover -v`
  - Caso contrário → usa `python -m pytest -v`

- **Virtual Environment**: Procura por venv nas seguintes pastas (nessa ordem):
  - `venv`
  - `.venv`
  - `env`
  - `.env`

- **pytest.ini**: Cria automaticamente o arquivo `pytest.ini` com `pythonpath = .` se não existir, garantindo que o pytest encontre os módulos na raiz do projeto.

## Requisitos

- Windows (o executável foi criado para Windows)
- O projeto deve ser um repositório Git (ter pasta `.git`)
- Python instalado no sistema (para rodar os testes, não para executar o .exe)

## Desabilitar Temporariamente

Se precisar fazer um commit sem rodar os testes:

```bash
git commit --no-verify -m "sua mensagem"
```

## Personalização

Para modificar quais testes são executados, edite o arquivo `.git/hooks/pre-commit` após a configuração.
