import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import {
  architectureExperience,
  comparisonExperience,
  flowExperience,
  invalidExperience,
  responsibilityExperience,
} from '../../test/visualExperienceFixtures'
import { VisualExperienceRenderer } from './VisualExperienceRenderer'

describe('VisualExperienceRenderer', () => {
  it.each([
    ['comparison', comparisonExperience(), 'Comparação'],
    ['architecture', architectureExperience(), 'Arquitetura'],
    ['flow', flowExperience(), 'Fluxo'],
    ['responsibility', responsibilityExperience(), 'Responsabilidade'],
  ] as const)('despacha %s para o renderer correto', (_type, experience, label) => {
    render(<VisualExperienceRenderer experience={experience} />)

    expect(screen.getByText(label)).toBeInTheDocument()
    expect(screen.getByRole('article', { name: experience.title })).toBeInTheDocument()
  })

  it('mostra fallback para experiência inválida', () => {
    render(<VisualExperienceRenderer experience={invalidExperience()} />)

    expect(screen.getByRole('alert')).toHaveTextContent(
      'Não foi possível carregar esta visualização.',
    )
  })

  it('renderiza strings parecidas com HTML como texto inerte', () => {
    const htmlLikeText = '<img src=x onerror=alert(1)><script>alert(1)</script>'
    const experience = comparisonExperience({
      title: htmlLikeText,
      config: {
        columns: [
          { id: 'safe-one', title: htmlLikeText },
          { id: 'safe-two', title: 'Opção segura' },
        ],
        rows: [
          {
            id: 'safe-row',
            label: 'Conteúdo',
            values: { 'safe-one': htmlLikeText, 'safe-two': 'Texto normal' },
          },
        ],
      },
    })

    const { container } = render(<VisualExperienceRenderer experience={experience} />)

    expect(container).toHaveTextContent(htmlLikeText)
    expect(container.querySelector('script')).not.toBeInTheDocument()
    expect(container.querySelector('img')).not.toBeInTheDocument()
  })
})

describe('ComparisonVisual', () => {
  it('expõe a comparação como tabela semântica e cards descritivos', () => {
    const experience = comparisonExperience()
    render(<VisualExperienceRenderer experience={experience} />)

    const table = screen.getByRole('table', { name: experience.title })
    expect(within(table).getByRole('columnheader', { name: 'Critério' })).toBeInTheDocument()
    expect(within(table).getByRole('columnheader', { name: /IaaS/ })).toBeInTheDocument()
    expect(within(table).getByRole('rowheader', { name: 'Sistema operacional' })).toBeInTheDocument()
    expect(within(table).getByRole('cell', { name: 'Gerenciado pelo cliente' })).toBeInTheDocument()

    expect(screen.getByRole('region', { name: `Tabela comparativa: ${experience.title}` }))
      .toHaveAttribute('tabindex', '0')
    for (const columnTitle of ['IaaS', 'PaaS', 'SaaS']) {
      expect(
        within(screen.getByRole('region', { name: columnTitle })).getByText(
          'Sistema operacional',
        ),
      ).toBeInTheDocument()
    }
  })
})

describe('ArchitectureVisual', () => {
  it('mantém o diagrama navegável em telas estreitas sem expandir a página', () => {
    const experience = architectureExperience()
    render(<VisualExperienceRenderer experience={experience} />)

    const scrollRegion = screen.getByRole('region', {
      name: `Diagrama de arquitetura: ${experience.title}`,
    })
    const canvas = scrollRegion.firstElementChild

    expect(scrollRegion).toHaveClass('overflow-x-auto', 'overscroll-x-contain')
    expect(canvas).toHaveClass('min-w-[42rem]')
  })

  it('oferece representação textual das relações e oculta o SVG decorativo', () => {
    const experience = architectureExperience()
    const { container } = render(<VisualExperienceRenderer experience={experience} />)

    expect(screen.getByText(/Relação de Internet para API\. HTTPS\./)).toBeInTheDocument()
    expect(container.querySelector('svg')).toHaveAttribute('aria-hidden', 'true')
    expect(screen.getByRole('region', { name: `Diagrama de arquitetura: ${experience.title}` }))
      .toHaveAttribute('tabindex', '0')
  })

  it('mostra e oculta os detalhes de um node por interação acessível', async () => {
    const user = userEvent.setup()
    render(<VisualExperienceRenderer experience={architectureExperience()} />)

    const apiButton = screen.getByRole('button', { name: /API, Serviço\. Mostrar detalhes\./ })
    const detailsId = apiButton.getAttribute('aria-controls')
    const details = detailsId ? document.getElementById(detailsId) : null

    expect(details).not.toBeNull()
    expect(apiButton).toHaveAttribute('aria-expanded', 'false')
    expect(within(details as HTMLElement).getByText('Nenhum componente selecionado.'))
      .toBeInTheDocument()

    await user.click(apiButton)

    expect(apiButton).toHaveAttribute('aria-expanded', 'true')
    expect(within(details as HTMLElement).getByRole('heading', { name: 'API' })).toBeInTheDocument()
    expect(within(details as HTMLElement).getByText('Recebe e processa o tráfego.'))
      .toBeInTheDocument()

    await user.click(apiButton)

    expect(apiButton).toHaveAttribute('aria-expanded', 'false')
    expect(within(details as HTMLElement).getByText('Nenhum componente selecionado.'))
      .toBeInTheDocument()
  })
})

describe('FlowVisual', () => {
  it('expõe a sequência como lista ordenada na ordem configurada', () => {
    const experience = flowExperience()
    render(<VisualExperienceRenderer experience={experience} />)

    const list = screen.getByRole('list', { name: `Etapas de ${experience.title}` })
    const items = within(list).getAllByRole('listitem')

    expect(items).toHaveLength(3)
    expect(items[0]).toHaveTextContent('1Usuário')
    expect(items[1]).toHaveTextContent('2Entrar')
    expect(items[2]).toHaveTextContent('3Token')
  })
})

describe('ResponsibilityVisual', () => {
  it('troca de modelo, atualiza responsáveis e exibe a categoria compartilhada', async () => {
    const user = userEvent.setup()
    render(<VisualExperienceRenderer experience={responsibilityExperience()} />)

    expect(screen.getByRole('tab', { name: 'On-Premises' })).toHaveAttribute(
      'aria-selected',
      'true',
    )
    expect(screen.getByText('Você gerencia todas as camadas.')).toBeInTheDocument()

    await user.click(screen.getByRole('tab', { name: 'IaaS' }))
    expect(screen.getByText('O provedor assume a infraestrutura física.')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Datacenter físico — Microsoft Azure' }))
      .toBeInTheDocument()
    expect(screen.getByText('Exemplo para desenvolvedor .NET')).toBeInTheDocument()

    await user.click(screen.getByRole('tab', { name: 'PaaS' }))
    expect(screen.getByRole('button', { name: 'Sistema operacional — Microsoft Azure' }))
      .toBeInTheDocument()

    await user.click(screen.getByRole('tab', { name: 'SaaS' }))
    expect(screen.getByRole('button', { name: 'Aplicações — Compartilhada' }))
      .toBeInTheDocument()
  })

  it('expande e recolhe os detalhes de uma camada', async () => {
    const user = userEvent.setup()
    render(<VisualExperienceRenderer experience={responsibilityExperience()} />)
    const layer = screen.getByRole('button', { name: 'Dados — Você' })

    expect(layer).toHaveAttribute('aria-expanded', 'false')
    await user.click(layer)
    expect(layer).toHaveAttribute('aria-expanded', 'true')
    expect(screen.getByText('Informações da organização.')).toBeInTheDocument()
    await user.click(layer)
    expect(layer).toHaveAttribute('aria-expanded', 'false')
    expect(screen.queryByText('Informações da organização.')).not.toBeInTheDocument()
  })

  it('mantém a legenda completa e navega pelas abas com o teclado', async () => {
    const user = userEvent.setup()
    render(<VisualExperienceRenderer experience={responsibilityExperience()} />)

    const legend = screen.getByRole('complementary', { name: 'Legenda de responsabilidades' })
    expect(within(legend).getByText('Você')).toBeInTheDocument()
    expect(within(legend).getByText('Microsoft Azure')).toBeInTheDocument()
    expect(within(legend).getByText('Compartilhada')).toBeInTheDocument()

    const onPremisesTab = screen.getByRole('tab', { name: 'On-Premises' })
    onPremisesTab.focus()
    await user.keyboard('{ArrowRight}')
    expect(screen.getByRole('tab', { name: 'IaaS' })).toHaveFocus()
    expect(screen.getByRole('tab', { name: 'IaaS' })).toHaveAttribute('aria-selected', 'true')
    await user.keyboard('{End}')
    expect(screen.getByRole('tab', { name: 'SaaS' })).toHaveFocus()
    await user.keyboard('{Home}')
    expect(onPremisesTab).toHaveFocus()
  })
})
