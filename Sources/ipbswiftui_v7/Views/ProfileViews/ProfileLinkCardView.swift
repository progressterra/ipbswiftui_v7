//
//  ProfileLinkCardView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 22.08.2023.
//

import SwiftUI

public struct ProfileLinkCardView: View {
    @EnvironmentObject var vm: ProfileViewModel
    
    let action: () -> ()
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if let profileImageURL = vm.profileImageURL {
                    AsyncImageView(
                        imageURL: profileImageURL,
                        width: 80,
                        height: 80,
                        cornerRadius: 40
                    )
                    .padding(.trailing, 20)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.trailing, 20)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(vm.name + " " + vm.surname)
                        .font(Style.title)
                        .foregroundColor(Style.textSecondary)
                        .multilineTextAlignment(.leading)
                    Text(vm.email)
                        .font(Style.footnoteRegular)
                        .foregroundColor(Style.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Style.iconsPrimary)
            }
            .padding()
        }
        .background(Style.surface)
        .cornerRadius(8)
    }
}

struct ProfileLinkCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ProfileLinkCardView(action: {})
        }
    }
}
