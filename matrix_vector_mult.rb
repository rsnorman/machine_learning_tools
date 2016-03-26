require 'pry'

class PredictionData
  attr_reader :data

  def initialize(*data)
    @data = data.map(&:freeze)
  end

  def to_matrix
    # data.length * 2 matrix
    Matrix.new(data.map do |datum|
      [1, datum]
    end)
  end
end

class Formula
  attr_reader :scalar, :offset

  def initialize(scalar: 1, offset: 0)
    @scalar = scalar
    @offset = offset
  end

  def to_matrix
    Matrix.new([[offset], [scalar]]) # 2 * 1 matrix
  end
end

class MatrixVectorMultiplier
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def multiply(vector_matrix)
    vector_matrix = vector_matrix.data.flatten
    Matrix.new(matrix.data.map do |el|
      [el.first * vector_matrix.first + el.last * vector_matrix.last]
    end)
  end
end

class MatrixPrinter
  def initialize(matrix)
    @matrix = matrix
  end

  def print(title: 'Matrix')
    col_sizes = []
    matrix.each do |row|
      row.each_with_index do |el, index|
        col_sizes[index] ||= 0
        col_sizes[index] = el.to_s.size if col_sizes[index] < el.to_s.size
      end
    end

    padded_matrix = matrix.map do |row|
      row.map.with_index do |el, index|
        "#{spaces(col_sizes[index] - el.to_s.size)}#{el}"
      end
    end

    print_matrix = padded_matrix.map do |row|
      "| #{row.map(&:to_s).join(', ')} |"
    end

    puts title
    puts "--#{spaces(print_matrix.first.size - 4)}--"
    print_matrix.each { |row| puts row }
    puts "--#{spaces(print_matrix.first.size - 4)}--"
  end

  private

  def spaces(amount)
    space_str = ''
    amount.times do
      space_str += ' '
    end
    space_str
  end

  attr_reader :matrix
end

class MatrixMultiplier
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def multiply(other_matrix)
    other_matrix = inflect(other_matrix.data)
    Matrix.new(matrix.data.map do |row|
      other_matrix.map.with_index do |other_row, index|
        row.map.with_index do |el, col_index|
          el * other_row[col_index]
        end.inject { |sum, el| sum + el }
      end
    end)
  end

  private

  def inflect(matrix)
    inflected_matrix = Array.new(matrix.first.size) { Array.new(matrix.size) }
    matrix.each.with_index do |row, row_index|
      row.each.with_index do |el, col_index|
        inflected_matrix[col_index][row_index] = el
      end
    end
    inflected_matrix
  end
end

class MatrixCombiner
  attr_reader :matrices

  def initialize(*matrices)
    @matrices = matrices
  end

  def combine
    combined_matrix = Array.new(matrices.first.rows) { Array.new(matrices.size) }
    matrices.each.with_index do |matrix, col_index|
      matrix.data.each.with_index do |row, row_index|
        row.each do |el|
          combined_matrix[row_index][col_index] = el
        end
      end
    end
    Matrix.new(combined_matrix)
  end
end

class Matrix
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def rows
    data.size
  end

  def cols
    data.first.size
  end

  def print(title: 'Matrix')
    MatrixPrinter.new(data).print(title: title)
  end
end

data = PredictionData.new(2104, 1416, 1534, 852)
formula = Formula.new(scalar: 0.25, offset: -40)
formula2 = Formula.new(scalar: 0.1, offset: 200)
formula3 = Formula.new(scalar: 0.4, offset: -150)

data.to_matrix.print(title: 'Prediction Data')
formula.to_matrix.print(title: 'Hypothesis Vector 1')
formula2.to_matrix.print(title: 'Hypothesis Vector 2')
formula3.to_matrix.print(title: 'Hypothesis Vector 3')

vector_mult_matrix = MatrixVectorMultiplier.new(data.to_matrix).multiply(formula.to_matrix)
vector_mult_matrix2 = MatrixVectorMultiplier.new(data.to_matrix).multiply(formula2.to_matrix)
vector_mult_matrix3 = MatrixVectorMultiplier.new(data.to_matrix).multiply(formula3.to_matrix)

vector_mult_matrix.print(title: 'Predictions')
vector_mult_matrix2.print(title: 'Predictions 2')
vector_mult_matrix3.print(title: 'Predictions 3')

formulas = MatrixCombiner.new(formula.to_matrix, formula2.to_matrix, formula3.to_matrix).combine

formulas.print(title: 'All Predictions')

mult_matrix = MatrixMultiplier.new(data.to_matrix).multiply(formulas)
mult_matrix.print(title: 'Matrix Predictions')

