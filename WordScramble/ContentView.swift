//
//  ContentView.swift
//  WordScramble
//
//  Created by Hamza Osama on 8/20/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showScoreAlert = false
    
    var score: Int {
            usedWords.reduce(0) { $0 + $1.count }
        }
    
//    var score: [Int] {
//           usedWords.map { $0.count }
//    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationBarTitle(rootWord, displayMode: .automatic)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button {
                    showScoreAlert = true
                }label: {
                    Text("\(score)")
                        .font(.system(size: 40))
                        .padding()
                        .foregroundColor(.primary)
                }
                .alert(isPresented: $showScoreAlert) {
                    Alert(
                        title: Text("This is your score"),
                        message: Text("Score works by adding the number of all letters in all the words you got")
                    )
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                startGame()
            }label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
                
            }
            .padding()
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used alredy", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "word not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know")
            return
        }
        
        guard checkThree(word: answer) else {
            wordError(title: "Word less than 3 letters", message: "Think bigger")
            return
        }
        
        guard checkRoot(word: answer) else {
            wordError(title: "You can't enter the root word", message: "Be more creative 😁")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                newWord = ""
//                score = [0]
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func checkThree(word: String) -> Bool {
        if newWord.count <= 2 {
            return false
        } else {
            return true
        }
    }
    
    func checkRoot(word: String) -> Bool {
        if newWord == rootWord {
            return false
        } else {
            return true
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
