import SwiftUI

struct TemasView: View {
    @EnvironmentObject private var temas: TemaStore

    var body: some View {
        List(Tema.todos) { tema in
            Button {
                temas.selecionado = tema.id
            } label: {
                HStack {
                    Circle().fill(tema.cor).frame(width: 22, height: 22)
                    Text(tema.nome).foregroundStyle(.primary)
                    Spacer()
                    if temas.selecionado == tema.id {
                        Image(systemName: "checkmark")
                            .foregroundStyle(tema.cor)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("Temas")
    }
}
