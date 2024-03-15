//
//  OrderStageView.swift
//  
//
//  Created by Artemy Volkov on 24.08.2023.
//

import SwiftUI

public struct OrderStageView: View {
    var currentStageIndex: Int
    let stages: [String]
    
    public init(currentStageIndex: Int, stages: [String]) {
        self.currentStageIndex = currentStageIndex
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
                            .foregroundStyle( Style.primary)
                            .offset(y: 30)
                            .frame(width: 80, height: 20)
                    }
                    
                } else if currentStageIndex < stageIndex {
                    futureStage
                        .overlay {
                            Text(stages[stageIndex])
                                .font(Style.body)
                                .foregroundStyle(Style.textDisabled)
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
            .foregroundStyle( Style.primary)
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
            .foregroundStyle(Style.iconsPrimary)
            .clipShape(Circle())
    }
    
    private var futureStage: some View {
        Circle()
            .stroke()
            .frame(height: 12)
            .background(Style.surface)
            .foregroundStyle(Style.iconsDisabled)
            .clipShape(Circle())
    }
    
    private var passedStage: some View {
        Image("checkMark", bundle: .module)
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundStyle( Style.primary)
            .background(Style.surface)
            .overlay {
                Circle()
                    .stroke()
                    .foregroundStyle( Style.primary)
            }
            .clipShape(Circle())
    }
}
