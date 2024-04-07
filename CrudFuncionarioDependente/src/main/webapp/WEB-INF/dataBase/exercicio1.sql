USE master
CREATE DATABASE aulafunction
GO

USE aulafunction 

GO
CREATE TABLE funcionario ( 
codigo			INT			 NOT NULL, 
nome			VARCHAR(50)  NULL,
salario			DECIMAL(7,2) NULL
PRIMARY KEY (codigo)
)
GO

CREATE TABLE dependente(
codigo		INT			 NOT NULL, 
nome			VARCHAR(50)   NULL, 
salario		DECIMAL(7,2)  NULL,
funcionario		INT			 NULL 
PRIMARY KEY (codigo)
FOREIGN KEY (funcionario) REFERENCES funcionario(codigo) 
)
GO

INSERT INTO funcionario (codigo, nome, salario)
VALUES
    (1, 'João Silva', 500.0),
    (2, 'Maria Oliveira', 550),
    (3, 'Carlos Santos', 480),
    (4, 'Ana Pereira', 520),
    (5, 'Paulo Oliveira', 530),
    (6, 'Juliana Martins', 510.32),
    (7, 'Lucas Silva', 4900.00),
    (8, 'Mariana Santos', 54000),
    (9, 'Pedro Oliveira', 4700),
    (10, 'Camila Martins', 5600);

INSERT INTO dependente VALUES
    (1, 'João Silva Filho', 1500.00, 1),
    (2, 'Maria Oliveira Filha', 9900.00, 1),
    (3, 'Pedro Santos Filho', 9750.00, 1),
    (4, 'Ana Costa Filha', 20003.00, 2),
    (5, 'Carlos Pereira Filho', 500.00, 3),
    (6, 'Luísa Martins Filha', 40060.00, 4),
    (7, 'Lucas Fernandes Filho', 950.00, 5),
    (8, 'Mariana Almeida Filha', 860.00, 6),
    (9, 'Rafael Lima Filho', 120.00, 7),
    (10, 'Tatiane Souza Filha', 1020.00, 8);

--1. Criar uma database, criar as tabelas abaixo, definindo o tipo de dados e a relação PK/FK e popular com alguma massa de dados de teste (Suficiente para testar UDFs)
--Funcionário (Código, Nome, Salário)
--Dependendente (Código_Dep, Código_Funcionário, Nome_Dependente, Salário_Dependente)
--a) Código no Github ou Pastebin de uma Function que Retorne uma tabela:
--(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)

CREATE FUNCTION fn_funcionarios_dependentes()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.codigo AS codigoDependente, 
        f.codigo AS codigoFuncionario,
        f.nome AS nomeFuncionario,
        d.nome AS nomeDependente,
		d.salario AS salarioDependente,
		f.salario AS salarioFuncionario
    FROM funcionario f 
    INNER JOIN dependente d ON f.codigo = d.funcionario
);

SELECT * FROM fn_funcionarios_dependentes()


CREATE FUNCTION fn_consultar_funcionarios_dependentes(@codigoFuncionario INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.codigo AS codigoDependente, 
        f.codigo AS codigoFuncionario,
        f.nome AS nomeFuncionario,
        d.nome AS nomeDependente,
		d.salario AS salarioDependente,
		f.salario AS salarioFuncionario
    FROM 
        funcionario f 
    INNER JOIN 
        dependente d ON f.codigo = d.funcionario
    WHERE
        f.codigo = @codigoFuncionario
);

SELECT * FROM fn_consultar_funcionarios_dependentes(1);



--b) Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário. 

CREATE FUNCTION fn_soma_salario (@codigoFuncionario INT)
RETURNS DECIMAL(7,2)
AS
BEGIN
    DECLARE @totalSalario DECIMAL(7,2);

    SELECT @totalSalario = ISNULL(SUM(d.salario), 0) + ISNULL(f.salario, 0)
    FROM funcionario f
    LEFT JOIN dependente d ON f.codigo = d.funcionario
    WHERE f.codigo = @codigoFuncionario
    GROUP BY f.salario;

    RETURN @totalSalario;
END;

SELECT dbo.fn_soma_salario(4) AS "Soma Salarios"

CREATE PROCEDURE sp_iud_funcionario 
    @acao CHAR(1), 
    @codigo INT, 
    @nome VARCHAR(50), 
    @salario DECIMAL(7,2),
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF (@acao = 'I')
    BEGIN
        INSERT INTO funcionario (codigo, nome, salario) 
        VALUES (@codigo, @nome, @salario)
        SET @saida = 'Funcionário inserido com sucesso'
    END
    ELSE IF (@acao = 'U')
    BEGIN
        UPDATE funcionario 
        SET nome = @nome, salario = @salario
        WHERE codigo = @codigo
        SET @saida = 'Funcionário alterado com sucesso'
    END
    ELSE IF (@acao = 'D')
    BEGIN
        IF EXISTS (SELECT 1 FROM funcionario WHERE codigo = @codigo)
        BEGIN
            DELETE FROM funcionario WHERE codigo = @codigo
            SET @saida = 'Funcionário excluído com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Funcionário não encontrado'
        END
    END
    ELSE
    BEGIN
        RAISERROR('Operação inválida', 16, 1)
        RETURN
    END
END

CREATE PROCEDURE sp_iud_dependente 
    @acao CHAR(1), 
    @codigo INT, 
    @nome VARCHAR(50), 
    @salario DECIMAL(7,2),
    @funcionario INT,
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF (@acao = 'I')
    BEGIN
        INSERT INTO dependente(codigo, nome, salario, funcionario) 
        VALUES (@codigo, @nome, @salario, @funcionario)
        SET @saida = 'Dependente inserido com sucesso'
    END
    ELSE IF (@acao = 'U')
    BEGIN
        UPDATE dependente 
        SET nome = @nome, salario = @salario, funcionario = @funcionario
        WHERE codigo = @codigo
        SET @saida = 'Dependente alterado com sucesso'
    END
    ELSE IF (@acao = 'D')
    BEGIN
        IF EXISTS (SELECT 1 FROM dependente WHERE codigo = @codigo)
        BEGIN
            DELETE FROM dependente WHERE codigo = @codigo
            SET @saida = 'Dependente excluído com sucesso'
        END
        ELSE
        BEGIN
            SET @saida = 'Dependente não encontrado'
        END
    END
    ELSE
    BEGIN
        RAISERROR('Operação inválida', 16, 1)
        RETURN
    END
END



CREATE TABLE produto(
codigo					INT			NOT NULL, 
nome					VARCHAR(30) NOT NULL,
valorUnitario			DECIMAL(7,2)NOT NULL,
qtdEstoque				INT			NOT NULL
PRIMARY KEY (codigo)
)
GO

-- Inserir 10 registros na tabela produto
INSERT INTO produto (codigo, nome, valorUnitario, qtdEstoque)
VALUES
    (1, 'Produto 1', 10.50, 100),
    (2, 'Produto 2', 15.75, 150),
    (3, 'Produto 3', 20.25, 200),
    (4, 'Produto 4', 12.99, 120),
    (5, 'Produto 5', 8.50, 80),
    (6, 'Produto 6', 18.75, 180),
    (7, 'Produto 7', 22.00, 220),
    (8, 'Produto 8', 9.99, 90),
    (9, 'Produto 9', 16.50, 160),
    (10, 'Produto 10', 25.00, 250);

--a) a partir da tabela Produtos (codigo, nome, valor unitário e qtd estoque), quantos produtos estão com estoque abaixo de um valor de entrada
CREATE FUNCTION fn_quantidadeEstoque (@valorMinimo INT)
RETURNS INT
AS
BEGIN
    DECLARE @qtdEstoqueAbaixo INT;

    SELECT @qtdEstoqueAbaixo = COUNT(*)
    FROM produto
    WHERE qtdEstoque < @valorMinimo;

    RETURN @qtdEstoqueAbaixo;
END;

SELECT dbo.fn_quantidadeEstoque(120) AS "Quantidade Estoque"

--b) Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque abaixo de um valor de entrada

CREATE FUNCTION fn_produtosEstoque (@valor INT)
RETURNS TABLE
AS
RETURN (
    SELECT codigo, nome, qtdEstoque
    FROM produto
    WHERE qtdEstoque < @valor
);

SELECT * FROM dbo.fn_produtosEstoque(120)

--3. Criar, uma UDF, que baseada nas tabelas abaixo, retorne
--Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje
--Tabelas iniciais:
--Cliente (Codigo, nome)
--Produto (Codigo, nome, valor)


CREATE TABLE cliente (
    codigo INT,
    nome VARCHAR(50)
	PRIMARY KEY (codigo)
)
GO

CREATE TABLE produto1 (
    codigo INT ,
    nome VARCHAR(50),
    valor DECIMAL(7,2)
	
)
GO

CREATE TABLE venda (
    cliente INT,
    produto INT,
    qtd INT,
    dataCompra DATE,
    FOREIGN KEY (cliente) REFERENCES cliente(Codigo),
    FOREIGN KEY (produto) REFERENCES produto(Codigo)
)
GO

CREATE FUNCTION fn_calculo()
RETURNS @tabela TABLE (
Nome_cliente VARCHAR(100),
Nome_produto VARCHAR(100),
qtd_p INT,
valot_tot DECIMAL(10, 2),
data_hoje DATE
) 
BEGIN
 
    INSERT INTO @tabela(Nome_cliente, Nome_produto, qtd_p, valot_tot, data_hoje )
	     SELECT C.nome, P.Nome, COUNT(P.Codigo) AS qtd_p, SUM(p.valorUnitario) AS valor_tot, GETDATE() as data_hoje
		 FROM Cliente C
		 INNER JOIN produto p ON p.codigo = c.codigo
		 GROUP BY c.nome, p.nome;
		 RETURN
END
 SELECT * FROM fn_calculo()




