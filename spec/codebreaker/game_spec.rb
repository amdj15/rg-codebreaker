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
      let(:win_combination) { "3456" }

      before do
        subject.secret = win_combination
      end

      it "must be empty when doesnt match" do
        expect(subject.guess "1212").to be_empty
      end

      it "must be ++- when assumption 2 numbrs match exect and 1 position missed" do
        expect(subject.guess "3461").to eq("++-")
      end

      it "decrement number of available attempts" do
        expect{subject.guess "3461"}.to change{subject.attempts}.by(-1)
      end

      it "increment number of turns" do
        expect{subject.guess "3461"}.to change{subject.instance_variable_get(:@turns)}.by(1)
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

      context "combination when numbers are repeated:" do
        before do
          subject.secret = "1134"
        end

        it "should be ++ when 1335 and secret 1134" do
          expect(subject.guess "1335").to eq "++"
        end

        it "should be +- when 1325 and secret 1134" do
          expect(subject.guess "1325").to eq("+-")
        end

         it "should be + when 3333 and secret 1134" do
          expect(subject.guess "3333").to eq("+")
        end
      end

      context "Game over:" do
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