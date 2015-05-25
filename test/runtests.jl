import GloVe
using Base.Test

# LookupTable
l1 = GloVe.LookupTable()
l1["a"] = 1
l1["naive"] = 2
l1["fox"] = 3

@test l1["a"] == 1 && l1[1] == "a"
@test l1["naive"] == 2 && l1[2] == "naive"
@test l1["fox"] == 3 && l1[3] == "fox"
@test haskey(l1, "a") && haskey(l1, 1)
@test haskey(l1, "naive") && haskey(l1, 2)
@test haskey(l1, "fox") && haskey(l1, 3)

l2 = GloVe.LookupTable(["a", "naive", "fox"], [1,2,3])
l3 = GloVe.LookupTable([1,2,3], ["a", "naive", "fox"])

@test l1 == l2 && l2 == l3

# Test from python GloVe implementation.
# https://github.com/maciejkula/glove-python/tree/master/glove/tests
vocab = Dict(zip(["a", "naive", "fox"], [1,2,3]))
corpus = ["a naive fox"]

comatrix = GloVe.make_cooccur(vocab, corpus)
expected = [0.0 1.0 0.5; 1.0 0.0 1.0; 0.5 1.0 0.0]

@test full(comatrix) == expected

# Mock corpus (from Gensim word2vec tests)
corpus = split("""human interface computer
survey user computer system response time
eps user interface system
system human system eps
user response time
trees
graph trees
graph minors trees
graph minors survey
I like graph and stuff
I like trees and stuff
Sometimes I build a graph
Sometimes I build trees""", '\n')

vocab = GloVe.make_vocab(corpus)
comatrix = GloVe.make_cooccur(vocab, corpus)
model = GloVe.Model(comatrix, vecsize=10)

# The corpus is very, very small.
# So even with a large amount of iterations
# this test may fail.
solver = GloVe.Adagrad(1000)
GloVe.train!(model, solver)

id2word = Dict{Int, String}()
for (w, id) = vocab
    id2word[id] = w
end

# model is trained
M = model.W_main + model.W_ctx
top_words = GloVe.similar_words(M, vocab, id2word, "trees", n=10)[1:3]
@test in("graph", top_words)
top_words = GloVe.similar_words(M, vocab, id2word, "graph", n=10)[1:3]
@test in("trees", top_words)

