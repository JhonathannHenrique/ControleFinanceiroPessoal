# Controle Financeiro Pessoal

Aplicativo de controle financeiro pessoal desenvolvido em Flutter com banco de dados SQLite local, utilizando o ORM **Floor**.

## Funcionalidades
- **Registro de Receitas e Despesas**: Cadastro de lançamentos com descrição, valor, tipo, data e categoria.
- **Categorização**: Organização dos lançamentos por categorias customizadas (nome e cor).
- **Cálculo de Saldo Total**: Exibição em tempo real do saldo total (Receitas - Despesas) calculado diretamente no SQLite via `rawQuery`.
- **Filtro de Lançamentos**: Filtro rápido por tipo (Todos / Receitas / Despesas).
- **Persistência Local Reativa**: Uso de Streams (`StreamBuilder`) para atualizar a interface em tempo real quando ocorrem alterações no banco de dados.
- **Deleção Segura**: Remoção de lançamentos com diálogo de confirmação.

## Modelagem do Banco de Dados (Diagrama ER)

O diagrama ER representa as tabelas e o relacionamento 1:N entre as entidades `Categoria` e `Lancamento`:

### Entidades e Atributos:
1. **Categoria**
   - `id`: INTEGER (Primary Key - Auto Incremento)
   - `nome`: TEXT (Not Null)
   - `cor`: TEXT (Not Null - Código Hexadecimal da cor)

2. **Lancamento**
   - `id`: INTEGER (Primary Key - Auto Incremento)
   - `descricao`: TEXT (Not Null)
   - `valor`: REAL (Not Null)
   - `tipo`: TEXT (Not Null - 'receita' ou 'despesa')
   - `data`: TEXT (Not Null - Data no formato ISO-8601)
   - `categoria_id`: INTEGER (Foreign Key referenciando `Categoria(id)`, com ação de deleção em cascata)

*Cardinalidade: Uma Categoria pode conter vários Lançamentos (1:N), e cada Lançamento pertence a exatamente uma Categoria.*

## Como Executar o Projeto

1. Certifique-se de ter o Flutter instalado em sua máquina.
2. Clone o repositório e navegue até a pasta do projeto.
3. Obtenha as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o gerador de código do Floor para criar o arquivo `app_database.g.dart`:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. Execute o aplicativo no seu emulador ou dispositivo físico:
   ```bash
   flutter run
   ```
