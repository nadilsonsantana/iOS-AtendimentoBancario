//
//  ViewController.m
//  AtendimentoBancario
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableViewClienteFila setDataSource:self];
    [tableViewClienteFila setDelegate:self];
    
    arrayClienteFila = [NSMutableArray new];
    
    [self mudarTipoEntrada:tipoEntrada];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)adicionarClienteNaFila:(id)sender
{
    NSNumberFormatter *numberFormat = [NSNumberFormatter new];
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *_clienteMinutoEntrada = [numberFormat numberFromString:[clienteMinutoEntrada text]];
    NSNumber *_clienteMinutoParaAtendimento = [numberFormat numberFromString:[clienteMinutoParaAtendimento text]];
    
    NSDictionary *dicClienteFila = @{@"clienteMinutoEntrada":_clienteMinutoEntrada,
                                     @"clienteMinutoParaAtendimento":_clienteMinutoParaAtendimento};
    
    [arrayClienteFila addObject:dicClienteFila];
    
    [tableViewClienteFila reloadData];
    
    NSLog(@"--- Iniciando Regra de Atendimento ---");
    
    [self aplicarRegraDeTempoDePermanenciaNaFila];
    
    NSLog(@"--- Finalizando Regra de Atendimento ---");
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayClienteFila count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString *_clienteMinutoEntrada = [[arrayClienteFila objectAtIndex:indexPath.row] objectForKey:@"clienteMinutoEntrada"];
    NSString *_clienteMinutoParaAtendimento = [[arrayClienteFila objectAtIndex:indexPath.row] objectForKey:@"clienteMinutoParaAtendimento"];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", _clienteMinutoEntrada, _clienteMinutoParaAtendimento]];
    
    return cell;
}

#pragma mark Entrada de Dados
- (void)mudarTipoEntrada:(UISegmentedControl *)tipo
{
    switch (tipoEntrada.selectedSegmentIndex)
    {
        //
        // C = Caixas Livres
        //
        case 0:
            [incrementoTipoEntrada setMaximumValue:10.0];
            [incrementoTipoEntrada setMinimumValue:1.0];
            [incrementoTipoEntrada setValue:[[bancoCaixaLivre text] floatValue]];
            break;
        //
        // T = Momento que Cliente entrou na Fila
        //
        case 1:
            [incrementoTipoEntrada setMaximumValue:300.0];
            [incrementoTipoEntrada setMinimumValue:0.0];
            [incrementoTipoEntrada setValue:[[clienteMinutoEntrada text] floatValue]];
            break;
        //
        // D = Tempo para Atendimento ao Cliente
        //
        case 2:
            [incrementoTipoEntrada setMaximumValue:10.0];
            [incrementoTipoEntrada setMinimumValue:1.0];
            [incrementoTipoEntrada setValue:[[clienteMinutoParaAtendimento text] floatValue]];
            break;
    }
}

- (void)incrementarValores:(UIStepper *)step
{
    switch (tipoEntrada.selectedSegmentIndex)
    {
        // Número de Caixas Livres para Atendimento
        case 0:
            [bancoCaixaLivre setText:[NSString stringWithFormat:@"%i", (int)step.value]];
            break;
        // Momento em que o Cliente entrou na Agência
        case 1:
            [clienteMinutoEntrada setText:[NSString stringWithFormat:@"%i", (int)step.value]];
            break;
        // Tempo para Atendimento do Cliente
        case 2:
            [clienteMinutoParaAtendimento setText:[NSString stringWithFormat:@"%i", (int)step.value]];
            break;
    }
}

#pragma mark Regras de Negócio
- (void)aplicarRegraDeTempoDePermanenciaNaFila
{
    int _tempoNaFila = 0;
    int _tempoAtendimentoClienteAnterior = 0;
    int _clienteNaFilaAcimaDoLimiteDeTempo = 0;
    int _bancoCaixaLivre = [[bancoCaixaLivre text] intValue];
    int _numeroDeClientesNaFila = [arrayClienteFila count];
    int _posicaoDoClienteNaFila = 1;
    int _caixaEmAtendimento = 0;
    
    NSMutableArray *_controleAtendimentoCaixa = [NSMutableArray new];
    
    // Percorrendo pela Fila de Atendimento
    for (NSDictionary *dic in arrayClienteFila)
    {
        // Pegando os valores de cada cliente
        int _clienteMinutoEntrada = [[dic objectForKey:@"clienteMinutoEntrada"] intValue];
        int _clienteMinutoParaAtendimento = [[dic objectForKey:@"clienteMinutoParaAtendimento"] intValue];
        
        // Existe Caixa para atender o Cliente?
        if (_posicaoDoClienteNaFila <= _bancoCaixaLivre)
        {
            _tempoAtendimentoClienteAnterior = 0;
            _tempoNaFila = 0;
            
            // Abrindo Caixa para Atendimento
            // e guardando o tempo de atendimento deste cliente por caixa
            [_controleAtendimentoCaixa addObject:[NSNumber numberWithInt:_clienteMinutoParaAtendimento]];
        }
       
        // Todos os Caixas estão ocupados
        if (_caixaEmAtendimento == _bancoCaixaLivre)
        {
            // Posicionando o Atendimento do próximo cliente para o 1o caixa
            _caixaEmAtendimento = 0;
        }
        
        // Cuidando dos Clientes na Fila
        if (_posicaoDoClienteNaFila > _bancoCaixaLivre)
        {
            // Guardando o tempo que este cliente levará
            // para ser atendido de acordo com o caixa
            _tempoAtendimentoClienteAnterior = [[_controleAtendimentoCaixa objectAtIndex:_caixaEmAtendimento] intValue];
        }
 
        // Somando o tempo que o cliente
        // a frente levará para ser atendimento
        // menos o momento em que este cliente chegou na agência
        _tempoNaFila = (_tempoAtendimentoClienteAnterior - _clienteMinutoEntrada);
        
        // Contabilizando atendimento nos Caixas
        _caixaEmAtendimento++;
        
        // Loop de Atendimento nos Caixas
        if (_caixaEmAtendimento > _bancoCaixaLivre)
        {
            _caixaEmAtendimento = 0;
        }
        
        // Verificando se este cliente ficará
        // mais de 20min na Fila para ser atendido
        if (_tempoNaFila > 20)
        {
            // Incrementando a quantidade de clientes
            // que ficarão na fila e levarão
            // mais de 20min para serem atendidos
            _clienteNaFilaAcimaDoLimiteDeTempo++;
        }
        
        NSLog(@"Cliente:%i - Caixa:%i - Atendimendo Anterior:%i - Tempo na Fila:%i",_posicaoDoClienteNaFila, _caixaEmAtendimento, _tempoAtendimentoClienteAnterior, _tempoNaFila);
        
        
        _posicaoDoClienteNaFila++;
    }
    
    // Exibindo na tela a quantidade de clientes
    // fora da Regra Bancária de 20min
    [clienteNaFilaAcimaDoLimiteDeTempo setText:[NSString stringWithFormat:@"%i", _clienteNaFilaAcimaDoLimiteDeTempo]];
}

- (IBAction)zerarAtendimento:(id)sender
{
    [arrayClienteFila removeAllObjects];
    [tableViewClienteFila reloadData];
    [clienteNaFilaAcimaDoLimiteDeTempo setText:@"0"];
}













@end
