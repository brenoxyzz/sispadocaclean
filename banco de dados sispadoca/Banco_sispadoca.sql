sql
-- ==========================================================
-- Padaria — Banco de Dados (starter completo)
-- Dialeto: MySQL
-- ==========================================================

-- Observação: usei UUID como CHAR(36) para compatibilidade.
-- Se preferir BINARY(16), ajuste os tipos.

SET sql_mode = 'STRICT_ALL_TABLES';

-- =====================
-- Tabela: Cadastro
-- =====================
CREATE TABLE IF NOT EXISTS Cadastro (
  id CHAR(36) NOT NULL,
  tipo VARCHAR(80) NOT NULL,
  nome VARCHAR(120) NOT NULL,
  descricao TEXT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_cadastro_tipo_nome (tipo, nome)
) ENGINE=InnoDB;

-- =====================
-- Tabela: clientes
-- =====================
CREATE TABLE IF NOT EXISTS clientes (
  id CHAR(36) NOT NULL,
  nome VARCHAR(160) NOT NULL,
  cpf VARCHAR(20) NULL,
  email VARCHAR(160) NULL,
  telefone VARCHAR(30) NULL,
  endereco TEXT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  data_nascimento DATE NULL,
  bairro TEXT NULL,
  cidade TEXT NULL,
  estado CHAR(2) NULL,
  sexo CHAR(1) NULL,
  observações TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_clientes_cpf (cpf),
  UNIQUE KEY idx_clientes_email (email)
) ENGINE=InnoDB;

-- =====================
-- Tabela: usuario
-- =====================
CREATE TABLE IF NOT EXISTS usuario (
  id CHAR(36) NOT NULL,
  nome_usuario VARCHAR(255) NULL,
  senha_hash VARCHAR(255) NOT NULL,
  email VARCHAR(255) NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  username VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY idx_usuario_username (username)
) ENGINE=InnoDB;

-- =====================
-- Tabela: produtos
-- =====================
CREATE TABLE IF NOT EXISTS produtos (
  id CHAR(36) NOT NULL,
  nome VARCHAR(160) NOT NULL,
  descricao TEXT NULL,
  preco_venda DECIMAL(12,2) NOT NULL,
  unidade VARCHAR(20) NOT NULL DEFAULT 'un',
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  preco_compra DECIMAL(12,2) NULL,
  NCM VARCHAR(255) NULL,
  lote VARCHAR(255) NULL,
  codigo_barras VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_produtos_codigo_barras (codigo_barras)
) ENGINE=InnoDB;

-- =====================
-- Tabela: fornecedores
-- =====================
CREATE TABLE IF NOT EXISTS fornecedores (
  id CHAR(36) NOT NULL,
  nome VARCHAR(160) NOT NULL,
  cnpj VARCHAR(20) NULL,
  email VARCHAR(160) NULL,
  telefone VARCHAR(30) NULL,
  endereco TEXT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_fornecedores_cnpj (cnpj),
  UNIQUE KEY idx_fornecedores_email (email)
) ENGINE=InnoDB;

-- =====================
-- Tabela: funcionarios
-- =====================
CREATE TABLE IF NOT EXISTS funcionarios (
  id CHAR(36) NOT NULL,
  nome VARCHAR(160) NOT NULL,
  cpf VARCHAR(20) NULL,
  cargo VARCHAR(80) NULL,
  telefone VARCHAR(30) NULL,
  usuario_id CHAR(36) NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  salario DECIMAL(12,2) NULL,
  carga_horaria DECIMAL(6,2) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_funcionarios_cpf (cpf),
  CONSTRAINT fk_funcionarios_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================
-- Tabela: estoque
-- =====================
CREATE TABLE IF NOT EXISTS estoque (
  id CHAR(36) NOT NULL,
  produto_id CHAR(36) NOT NULL,
  quantidade_atual DECIMAL(14,3) NOT NULL DEFAULT 0,
  quantidade_minima DECIMAL(14,3) NOT NULL DEFAULT 0,
  local VARCHAR(80) NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_estoque_produto (produto_id),
  CONSTRAINT fk_estoque_produtos
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================
-- Tabela: movimentações
-- =====================
CREATE TABLE IF NOT EXISTS movimentações (
  id CHAR(36) NOT NULL,
  data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo VARCHAR(30) NOT NULL,
  produto_id CHAR(36) NOT NULL,
  quantidade DECIMAL(14,3) NOT NULL,
  preco_unitario DECIMAL(12,2) NULL,
  observacao TEXT NULL,
  funcionario_id CHAR(36) NULL,
  fornecedor_id CHAR(36) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_movimentacoes_data_tipo (data, tipo),
  CONSTRAINT fk_mov_produtos
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_mov_funcionarios
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_mov_fornecedores
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================
-- Tabela: vendas
-- =====================
CREATE TABLE IF NOT EXISTS vendas (
  id CHAR(36) NOT NULL,
  numero VARCHAR(40) NULL,
  data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cliente_id CHAR(36) NULL,
  funcionario_id CHAR(36) NULL,
  forma_pagamento VARCHAR(60) NULL,
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  desconto DECIMAL(12,2) NOT NULL DEFAULT 0,
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  observacao TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_vendas_data (data),
  CONSTRAINT fk_vendas_clientes
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_vendas_funcionarios
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================
-- Tabela: venda_itens
-- =====================
CREATE TABLE IF NOT EXISTS venda_itens (
  id CHAR(36) NOT NULL,
  venda_id CHAR(36) NOT NULL,
  produto_id CHAR(36) NOT NULL,
  quantidade DECIMAL(14,3) NOT NULL,
  preco_unitario DECIMAL(12,2) NOT NULL,
  desconto_item DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_item DECIMAL(12,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_venda_itens_venda (venda_id),
  CONSTRAINT fk_venda_itens_vendas
    FOREIGN KEY (venda_id) REFERENCES vendas(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_venda_itens_produtos
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================
-- Tabela: contas
-- =====================
CREATE TABLE IF NOT EXISTS contas (
  id CHAR(36) NOT NULL,
  tipo VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'aberta',
  cliente_id CHAR(36) NULL,
  fornecedor_id CHAR(36) NULL,
  venda_id CHAR(36) NULL,
  valor DECIMAL(12,2) NOT NULL,
  data_emissao DATE NOT NULL DEFAULT (CURRENT_DATE),
  data_vencimento DATE NULL,
  data_pagamento DATE NULL,
  observacao TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_contas_status (status),
  KEY idx_contas_cliente (cliente_id),
  CONSTRAINT fk_contas_clientes
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_contas_fornecedores
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_contas_vendas
    FOREIGN KEY (venda_id) REFERENCES vendas(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================
-- Tabela: relatorios
-- =====================
CREATE TABLE IF NOT EXISTS relatorios (
  id CHAR(36) NOT NULL,
  tipo VARCHAR(60) NOT NULL,
  data_geracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  periodo_inicio DATE NULL,
  periodo_fim DATE NULL,
  gerado_por_usuario_id CHAR(36) NULL,
  titulo VARCHAR(200) NULL,
  conteudo_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_relatorios_tipo_data (tipo, data_geracao),
  CONSTRAINT fk_relatorios_usuario
    FOREIGN KEY (gerado_por_usuario_id) REFERENCES usuario(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================
-- Tabela: relatoria
-- =====================
CREATE TABLE IF NOT EXISTS relatoria (
  id CHAR(36) NOT NULL,
  relatorio_id CHAR(36) NOT NULL,
  tipo VARCHAR(60) NOT NULL,
  cliente_id CHAR(36) NULL,
  produto_id CHAR(36) NULL,
  fornecedor_id CHAR(36) NULL,
  venda_id CHAR(36) NULL,
  metricas_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_relatoria_relatorio_tipo (relatorio_id, tipo),
  CONSTRAINT fk_relatoria_relatorios
    FOREIGN KEY (relatorio_id) REFERENCES relatorios(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_relatoria_clientes
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_relatoria_produtos
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_relatoria_fornecedores
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_relatoria_vendas
    FOREIGN KEY (venda_id) REFERENCES vendas(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==========================================================
-- Fim
-- ==========================================================