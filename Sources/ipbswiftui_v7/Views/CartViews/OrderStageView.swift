//
//  OrderStageView.swift
//  
//
//  Created by Artemy Volkov on 24.08.2023.
//

import SwiftUI

public struct OrderStageView: View {
    @Binding var currentStageIndex: Int
    let stages: [String]
    
    public init(currentStageIndex: Binding<Int>, stages: [String]) {
        self._currentStageIndex = currentStageIndex
        self.stages = stages
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(stages.indices, id: \.self) { stageIndex in
                if currentStageIndex == stageIndex {
                    gradientLine
                    currentStage.overlay {
                        Text(stages[stageIndex])
                            .font(Style.headline)
                            .offset(y: 30)
                            .frame(width: 80, height: 20)
                    }
                    if stageIndex != stages.count {
                        line
                    }
                } else if currentStageIndex > stageIndex {
                    gradientLine
                    passedStage.overlay {
                        Text(stages[stageIndex])
                            .font(Style.body)
                            .gradientColor(gradient: Style.primary)
                            .offset(y: 30)
                            .frame(width: 80, height: 20)
                    }
                    
                } else if currentStageIndex < stageIndex {
                    futureStage
                        .overlay {
                            Text(stages[stageIndex])
                                .font(Style.body)
                                .foregroundColor(Style.textDisabled)
                                .offset(y: 30)
                                .frame(width: 80, height: 20)
                        }
                    line
                }
            }
            
            if currentStageIndex >= stages.count {
                gradientLine
            }
        }
        .animation(.linear, value: currentStageIndex)
        .padding(.horizontal, -50)
        .frame(height: 55, alignment: .top)
        .clipped()
    }
    
    private var gradientLine: some View {
        Rectangle()
            .frame(height: 2)
            .gradientColor(gradient: Style.primary)
    }
    
    private var line: some View {
        Rectangle()
            .frame(height: 1)
    }
    
    private var currentStage: some View {
        Circle()
            .stroke()
            .frame(height: 12)
            .background(Style.surface)
            .foregroundColor(Style.iconsPrimary)
            .clipShape(Circle())
    }
    
    private var futureStage: some View {
        Circle()
            .stroke()
            .frame(height: 12)
            .background(Style.surface)
            .foregroundColor(Style.iconsDisabled)
            .clipShape(Circle())
    }
    
    private var passedStage: some View {
        Image("checkMark", bundle: .module)
            .resizable()
            .frame(width: 16, height: 16)
            .gradientColor(gradient: Style.primary)
            .background(Style.surface)
            .overlay {
                Circle()
                    .stroke()
                    .gradientColor(gradient: Style.primary)
            }
            .clipShape(Circle())
    }
}
