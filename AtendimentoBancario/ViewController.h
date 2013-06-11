//
//  ViewController.h
//  AtendimentoBancario
//
//
//  Created by Nadilson Santana
//  Copyright (c) 2013 Nadilson Santana. All rights reserved.

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    //
    // C
    //
    // Número total de caixa livres para atendimento na agência
    // Maior/Igual a 1 e Menor/Igual a 10
    IBOutlet UILabel *bancoCaixaLivre;

    //
    // N
    //
    // Número total de clientes que procurarão atendimento na agência
    // Maior/Igual a 1 e Menor/Igual a 1000
    int clienteTotal;
    
    //
    // T
    //
    // Número em minutos que o cliente entrou na fila
    // Maior/Igual a 0 e Menor/Igual a 300
    IBOutlet UILabel *clienteMinutoEntrada;
    
    //
    // D
    //
    // Número em minutos que SERA ncessário para atender o cliente
    // Maior/Igual a 1 e Menor/Igual a 10
    IBOutlet UILabel *clienteMinutoParaAtendimento;
    
    //
    // Entrada
    //
    
    // Tipo de Entrada de Dado
    IBOutlet UISegmentedControl *tipoEntrada;
    IBOutlet UIStepper *incrementoTipoEntrada;
    
    // Listagem de clientes na fila de espera
    IBOutlet UITableView *tableViewClienteFila;
    NSMutableArray *arrayClienteFila;
    
    //
    // Saída
    //
    
    // Número de pessoas que ficarão na fila por mais de 20 minutos
    IBOutlet UILabel *clienteNaFilaAcimaDoLimiteDeTempo;
    
}

- (IBAction)mudarTipoEntrada:(UISegmentedControl *)tipo;
- (IBAction)incrementarValores:(UIStepper *)step;
- (IBAction)adicionarClienteNaFila:(id)sender;
- (IBAction)zerarAtendimento:(id)sender;

@end
