require 'spec_helper'

module Codebreaker
  describe Game do
    describe "#start" do
      it "generates secret code" do
        expect(subject.secret).not_to be_empty
      end

     it "saves 4 numbers secret code" do
        expect(subject.secret.length).to eq(4)
      end

      it "saves secret code with numbers from 1 to 6" do
        expect(subject.secret).to match(/[1-6]+/)
      end
    end

    describe "#guess" do
      it "decrement number of available attempts" do
        expect{subject.guess "3461"}.to change{subject.attempts}.by(-1)
      end

      it "increment number of turns" do
        expect{subject.guess "3461"}.to change{subject.instance_variable_get(:@turns)}.by(1)
      end

      cases = [
        ["1134", "1335", "++"],
        ["1134", "1325", "+-"],
        ["1134", "3333", "+"],
        ["3456", "3461", "++-"],
        ["1226", "1124", "++"],
        ["1234", "1654", "++"],
        ["1234", "4321", "----"],
        ["2242", "1456", "-"],
        ["1234", "1423", "+---"],
        ["1234", "3232", "++"],
        ["5314", "3224", "+-"],
        ["1213", "3121", "----"],
        ["5455", "4555", "++--"],
        ["3346", "4251", "-"],
        ["1256", "1355", "++"],
        ["1265", "1356", "+--"],
        ["1266", "1356", "++"],
        ["1122", "3523", "+"],
        ["1234", "2113", "---"],
        ["5435", "2612", ""],
        ["3335", "3355", "+++"],
        ["3335", "3553", "+--"],
        ["3335", "3555", "++"],
        ["3346", "1335", "+-"]
      ]

      cases.each do |kase|
        it "should be #{kase[2]} when code is #{kase[1]} and secret is #{kase[0]}" do
          subject.secret = kase[0]
          expect(subject.guess kase[1]).to eq(kase[2])
        end
      end

      context "Invalid assemption" do
        it "have to raise error" do
          expect{ subject.guess "3482" }.to raise_error
          expect{ subject.guess "23" }.to raise_error
          expect{ subject.guess "25466" }.to raise_error
          expect{ subject.guess "eeww" }.to raise_error
          expect{ subject.guess "ee" }.to raise_error
          expect{ subject.guess "212w" }.to raise_error
          expect{ subject.guess "22w" }.to raise_error
          expect{ subject.guess "1234w" }.to raise_error
          expect{ subject.guess "" }.to raise_error
        end
      end

      context "Game over:" do
         let(:win_combination) { "3456" }

        before do
          subject.secret = win_combination
        end

        context "win" do
          it do
            expect(subject.guess win_combination).to eq("++++")
          end
        end

        context "last attempt" do
          before do
            subject.attempts = 1;
          end

          it "\"Game over\" if miss" do
            expect(subject.guess "1212").to eq("Game over")
          end

          it "++++ if guess and win" do
            expect(subject.guess win_combination).to eq("++++")
          end
        end
      end
    end

    describe "#hint" do
      it "must return one of the number of secret code" do
        expect(subject.secret).to include(subject.hint)
      end

      it "have to return unshowen number" do
        expect{ subject.hint }.to change{ subject.instance_variable_get(:@allowed_hints).size }.by(-1)
      end

      context "all hints are used" do
        before do
          subject.instance_variable_set(:@allowed_hints, [])
        end

        it { expect(subject.hint).to be_nil }
      end
    end

    describe "#save" do
      it "have to open file for read and write data" do
        expect(File).to receive(:open).with(kind_of(String)).once
        expect(File).to receive(:open).with(kind_of(String), "w").once
        expect(Marshal).to receive(:load).and_return(Hash.new)

        subject.save "tester"
      end
    end
  end
end