# Whispers

> Um jogo em **Pixel Art** de exploração e suspense, desenvolvido em **Godot Engine**.

---

## Sobre o jogo
**Sussurros da Escuridão** é um jogo de sobrevivência e exploração em cavernas submersas.  O jogador controla **Half**, um jovem pesquisador de linguística da Stanford, enviado ao mar Egeu após a descoberta de uma fenda misteriosa que emite luzes enigmáticas.  Dentro da caverna, ele encontra um **portal de pedra com runas faltando** e precisa recuperá-las para ativá-lo.  

### Gêneros
- Sobrevivência
- Plataforma
- Suspense
- Mistério
- Descoberta
- História

---

## História
Nas profundezas de uma caverna próxima ao mar Egeu, uma fenda emite uma estranha luz. Half, sendo o único magro o suficiente para atravessar a passagem, é enviado para investigar. Ao entrar, encontra um arco de pedra com símbolos luminosos incompletos — **as runas foram levadas pelas correntes**.  Agora, ele deve enfrentar a escuridão, recuperar as cinco runas e retornar ao portal, sem ser abatido pelas criaturas marinhas.

---

## Jogabilidade
- Estilo **Pixel Art de exploração e sobrevivência**.
- O jogador deve **encontrar 5 runas** e levá-las uma a uma até o portal no início da caverna.
- A visibilidade é limitada: o jogador só enxerga bem quando há luz.
- O desafio está em despistar criaturas que habitam a escuridão.

---

## Itens e Equipamentos
- **Lanterna de mergulho**: intensidade média, ilumina parte do mapa, mas atrai monstros.
- **Lanterna de feixe fino e curto**: pouca intensidade, pouco perceptível.
- **Sonar**: mostra no canto da tela a posição aproximada dos monstros.
- **Arma supersônica**: atordoa algumas criaturas, mas pode irritá-las.

Os equipamentos podem ser **recarregados usando algas energizadas** espalhadas pelo mapa.

---

## Monstros (Aquapédia)
- **Luminífero**: criatura fluorescente que emite luz mesmo após a lanterna ser desligada; segue rotas fixas.
- **Peixe-espelho**: reflete a luz quando iluminado, podendo ser manipulado com o feixe fino.
- **Camuflante**: se mistura às paredes; só pode ser detectado pelo sonar.
- **Alga-polvo**: imobiliza o jogador por alguns segundos, mas ataca devagar.
- **Predador sônico**: veloz, persegue fontes sonoras (impactos, sonar, arma sônica), mas teme luz forte.

---

## Cenário
- Caverna escura com pedras, algas, trechos de lava.
- A escuridão domina o ambiente, exigindo uso inteligente da iluminação.

---

## Inspirações
- Jogos de sobrevivência e exploração em pixel art.
- Mistério e atmosfera semelhante a títulos como **Limbo** e **Hollow Knight**.
- Mistura de visão **lateral (plataforma)** e **top-down**, permitindo exploração variada.

---

## Tecnologias
- [Godot Engine 4.x](https://godotengine.org/)
- GDScript
- Git
---

## Estrutura do Projeto
```bash
Whispers /
├─ scenes/ # Cenas do jogo
├─ scripts/ # Scripts em GDScript
├─ assets/ # Sprites, sons e fontes
├─ docs/ # Documentação adicional
└─ README.md
```

---

## Fluxo de Trabalho (GitFlow)
- **main** → versão estável
- **develop** → integração de features
- **feature/** → novas funcionalidades
- **release/** → preparação de lançamentos
- **hotfix/** → correções críticas

Exemplo:
```bash
# Criando uma nova branch
git checkout develop
git fetch
git pull
git checkout -b feature/descrição-da-implementação

# Criando Commits
git add -A
git commit -m "feat/descrição-do-commit"
git push
```
## Como rodar
- Instale o Godot 4.x.
- Clone o repositório:

```bash
git clone https://github.com/Sahinake/Whispers.git
```
- Abra o projeto no Godot.
- Rode a cena principal Main.tscn.

## Roadmap Inicial
 - Criar tela inicial
 - Desenhar Tiles
 - Criar cenário da primeira fase
 - Criar sistema de iluminação
 - Implementar coleta das runas
 - Adicionar monstros e comportamentos
 - Implementar sonar e armas

 - Polimento e ambientação

