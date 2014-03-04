require "spec_helper"
require "models/services/validation_errors"

module VCAP::CloudController
  describe ValidationErrors do
    let!(:errors) { ValidationErrors.new }

    describe '#add' do
      it 'adds the error to the list of error messages' do
        errors.add('name must be unique')
        expect(errors.messages).to include('name must be unique')
      end

      it 'returns the error object' do
        expect(errors.add('name must be unique')).to eq(errors)
      end
    end

    describe '#add_nested' do
      let(:object_with_errors) { double(:object_with_errors) }

      it 'adds a nested error for the object' do
        errors.add_nested(object_with_errors)

        expect(errors.for(object_with_errors)).to be
      end

      it 'returns the nested error object' do
        nested_errors = errors.add_nested(object_with_errors)
        expect(nested_errors).not_to eq(errors)
        expect(nested_errors).to respond_to(:messages)
      end

      context 'when the nested errors already exist' do
        let!(:existing_nested_errors) { errors.add_nested(object_with_errors) }

        it 'returns the existing nested errors' do
          expect(errors.add_nested(object_with_errors)).to eq(existing_nested_errors)
        end
      end
    end

    describe '#empty?' do
      subject { errors.empty? }

      context 'when there are errors on the object' do
        before { errors.add('some message') }

        it { should be_false }
      end

      context 'when there are nested error objects' do
        let!(:nested_errors) { errors.add_nested(Object.new) }

        context 'and the nested error objects have no errors' do
          it { should be_true }
        end

        context 'and the nested error objects have errors' do
          before { nested_errors.add('something bad happened') }

          it { should be_false }
        end
      end

      context 'when there no errors on the object or any nested objects' do
        it { should be_true }
      end
    end

    describe '#nested_errors' do
      let(:nested_object){ double(:nested_object) }
      let!(:nested_errors) { errors.add_nested(nested_object) }

      it "returns the error object's nested errors hash" do
        expect(errors.nested_errors).to eq({ nested_object => nested_errors })
      end
    end
  end
end