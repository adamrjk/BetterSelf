import SwiftUI

struct TapToChangeBackgroundView: View {
    @State private var isToggled: Bool = false

    var body: some View {
        ZStack {
            (isToggled ? Color.purple : Color.orange)
                .ignoresSafeArea()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                isToggled.toggle()
            }
        }
    }
}

struct TapToChangeBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        TapToChangeBackgroundView()
    }
}


