import SwiftUI

// MARK: - Enums
enum ClinicalToolType: String {
    case gestationalAge
    case organDimensions
    case eGFR
    case scanProtocols
    case tirads
    case liverElastography
}

// MARK: - Gestational Age Calculator
struct GestationalAgeCalcView: View {
    @State private var lmpDate = Date()
    @State private var estimatedDueDate = Date()
    @State private var gestationalAge: String = "0 weeks 0 days"
    @AppStorage("themeColor") private var themeColorName = "Blue"
    
    var body: some View {
        Form {
            Section(header: Text("Patient Information")) {
                DatePicker("Last Menstrual Period (LMP)", selection: $lmpDate, displayedComponents: .date)
                    .onChange(of: lmpDate) { _, _ in calculateGA() }
            }
            
            Section(header: Text("Results")) {
                HStack {
                    Text("Validation Date")
                    Spacer()
                    Text(estimatedDueDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Gestational Age")
                    Spacer()
                    Text(gestationalAge)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                }
            }
        }
        .navigationTitle("Gestational Age Calc")
        .onAppear { calculateGA() }
    }
    
    private func calculateGA() {
        let calendar = Calendar.current
        if let edd = calendar.date(byAdding: .day, value: 280, to: lmpDate) {
            estimatedDueDate = edd
            
            let components = calendar.dateComponents([.day], from: lmpDate, to: Date())
            if let days = components.day {
                let weeks = days / 7
                let remainingDays = days % 7
                gestationalAge = "\(weeks) weeks \(remainingDays) days"
            }
        }
    }
}

// MARK: - Organ Dimensions
struct OrganDimensionsView: View {
    @State private var organType: String = "Liver"
    @State private var ageGroup: String = "Adult"
    
    let organs = ["Liver", "Spleen", "Kidney", "Gallbladder"]
    let ages = ["Neonate", "Pediatric", "Adult", "Geriatric"]
    
    var body: some View {
        Form {
            Section {
                Picker("Organ", selection: $organType) {
                    ForEach(organs, id: \.self) { Text($0) }
                }
                Picker("Age Group", selection: $ageGroup) {
                    ForEach(ages, id: \.self) { Text($0) }
                }
            }
            
            Section(header: Text("Reference Values")) {
                if organType == "Liver" {
                    LabeledContent("Normal Length", value: "12 - 15 cm")
                    LabeledContent("Borderline Hepatomegaly", value: "15.5 - 17 cm")
                    LabeledContent("Hepatomegaly", value: "> 17.5 cm")
                } else if organType == "Spleen" {
                    LabeledContent("Normal Length", value: "< 12 cm")
                    LabeledContent("Splenomegaly", value: "> 13 cm")
                } else {
                    LabeledContent("Normal Range", value: "Dependent on BSA")
                    Text("Detailed charts required for precise assessment.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Organ Dimensions")
    }
}

// MARK: - eGFR Calculator
struct EGFRCalculatorView: View {
    @State private var creatinine: Double = 1.0
    @State private var age: Double = 45
    @State private var isFemale = false
    @State private var isBlack = false
    
    var egfr: Double {
        // CKD-EPI Formula Equation (Simplified approximation)
        let k = isFemale ? 0.7 : 0.9
        let a = isFemale ? -0.329 : -0.411
        let minVal = min(creatinine / k, 1)
        let maxVal = max(creatinine / k, 1)
        
        var result = 141 * pow(minVal, a) * pow(maxVal, -1.209) * pow(0.993, age)
        
        if isFemale { result *= 1.018 }
        if isBlack { result *= 1.159 }
        
        return result
    }
    
    var body: some View {
        Form {
            Section(header: Text("Inputs")) {
                HStack {
                    Text("Serum Creatinine (mg/dL)")
                    Spacer()
                    TextField("1.0", value: $creatinine, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Age (years)")
                    Spacer()
                    Slider(value: $age, in: 18...100, step: 1)
                    Text("\(Int(age))")
                        .frame(width: 40)
                }
                
                Toggle("Female", isOn: $isFemale)
                Toggle("Black / African American", isOn: $isBlack)
            }
            
            Section(header: Text("Result")) {
                HStack {
                    Text("eGFR")
                    Spacer()
                    Text(String(format: "%.1f", egfr))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(egfr > 60 ? .green : .red)
                }
                Text("mL/min/1.73m²")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .navigationTitle("eGFR Calculator")
    }
}

// MARK: - Scan Protocols
struct ScanProtocolsView: View {
    let protocols = [
        "Abdominal Complete": ["Liver (Long/Trans)", "Gallbladder", "CBD", "Pancreas", "Spleen", "Kidneys", "Aorta"],
        "Thyroid": ["Right Lobe (Long/Trans)", "Left Lobe (Long/Trans)", "Isthmus", "Vascularity"],
        "Carotid Doppler": ["CCA PROX/MID/DIST", "Bulb", "ICA PROX/MID/DIST", "ECA", "Vertebral"]
    ]
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    var body: some View {
        List {
            ForEach(protocols.keys.sorted(), id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(protocols[key]!, id: \.self) { item in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(themeColor)
                            Text(item)
                        }
                    }
                }
            }
        }
        .navigationTitle("Scan Protocols")
    }
}

// MARK: - TIRADS Calculator
struct TiradsCalculatorView: View {
    @State private var composition = 0
    @State private var echogenicity = 0
    @State private var shape = 0
    @State private var margin = 0
    
    var totalScore: Int {
        composition + echogenicity + shape + margin
    }
    
    var tiradsLevel: String {
        switch totalScore {
        case 0...1: return "TR1 (Benign)"
        case 2: return "TR2 (Not Suspicious)"
        case 3: return "TR3 (Mildly Suspicious)"
        case 4...6: return "TR4 (Moderately Suspicious)"
        default: return "TR5 (Highly Suspicious)"
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Composition")) {
                Picker("Type", selection: $composition) {
                    Text("Cystic (0)").tag(0)
                    Text("Spongiform (0)").tag(0)
                    Text("Mixed cystic/solid (1)").tag(1)
                    Text("Solid (2)").tag(2)
                }
            }
            
            Section(header: Text("Echogenicity")) {
                Picker("Level", selection: $echogenicity) {
                    Text("Anechoic (0)").tag(0)
                    Text("Hyperechoic (1)").tag(1)
                    Text("Isoechoic (1)").tag(1)
                    Text("Hypoechoic (2)").tag(2)
                    Text("Very Hypoechoic (3)").tag(3)
                }
            }
            
            Section(header: Text("Shape")) {
                Picker("Orientation", selection: $shape) {
                    Text("Wider than tall (0)").tag(0)
                    Text("Taller than wide (3)").tag(3)
                }
            }
            
             Section(header: Text("Margin")) {
                Picker("Type", selection: $margin) {
                    Text("Smooth (0)").tag(0)
                    Text("Irregular (2)").tag(2)
                    Text("Lobulated (2)").tag(2)
                    Text("Extrathyroidal (3)").tag(3)
                }
            }
            
            Section(header: Text("Assessment")) {
                LabeledContent("Total Points", value: "\(totalScore)")
                HStack {
                    Text("TIRADS Level")
                    Spacer()
                    Text(tiradsLevel)
                        .fontWeight(.bold)
                        .foregroundColor(totalScore > 4 ? .red : .green)
                }
            }
        }
        .navigationTitle("TIRADS Calc")
    }
}

// MARK: - Liver Elastography
struct LiverElastographyView: View {
    @State private var stiffness: Double = 5.0
    @State private var etiology = "Hepatitis C"
    
    var fibrosisStage: String {
        // Simplified Logic based on roughly typical cutoffs
        if stiffness < 6.0 { return "F0/F1 (No/Mild Fibrosis)" }
        else if stiffness < 9.0 { return "F2 (Moderate Fibrosis)" }
        else if stiffness < 12.0 { return "F3 (Severe Fibrosis)" }
        else { return "F4 (Cirrhosis)" }
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Etiology", selection: $etiology) {
                    Text("Hepatitis C").tag("Hepatitis C")
                    Text("Hepatitis B").tag("Hepatitis B")
                    Text("NAFLD").tag("NAFLD")
                }
            }
            
            Section(header: Text("Measurements (kPa)")) {
                Slider(value: $stiffness, in: 2.0...30.0, step: 0.5)
                HStack {
                    Text("Stiffness")
                    Spacer()
                    Text("\(String(format: "%.1f", stiffness)) kPa")
                        .fontWeight(.bold)
                }
            }
            
            Section(header: Text("Interpretation")) {
                HStack {
                    Text("Fibrosis Stage")
                    Spacer()
                    Text(fibrosisStage)
                        .fontWeight(.bold)
                        .foregroundColor(stiffness > 12 ? .red : stiffness > 9 ? .orange : .green)
                }
            }
        }
        .navigationTitle("Elastography")
    }
}
