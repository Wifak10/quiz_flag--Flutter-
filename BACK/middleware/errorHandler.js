// Middleware de gestion globale des erreurs
const errorHandler = (err, req, res, next) => {
    console.error('Erreur capturée:', err);

    // Erreur de validation
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            success: false,
            message: 'Données invalides',
            errors: Object.values(err.errors).map(e => e.message)
        });
    }

    // Erreur JWT
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({
            success: false,
            message: 'Token invalide'
        });
    }

    // Erreur JWT expiré
    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
            success: false,
            message: 'Token expiré'
        });
    }

    // Erreur MySQL
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
            success: false,
            message: 'Cette donnée existe déjà'
        });
    }

    // Erreur par défaut
    res.status(err.status || 500).json({
        success: false,
        message: err.message || 'Erreur serveur interne',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};

// Middleware pour les routes non trouvées
const notFound = (req, res, next) => {
    const error = new Error(`Route non trouvée - ${req.originalUrl}`);
    error.status = 404;
    next(error);
};

// Middleware de validation des données
const validateRequest = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            return res.status(400).json({
                success: false,
                message: 'Données invalides',
                errors: error.details.map(detail => detail.message)
            });
        }
        next();
    };
};

module.exports = { errorHandler, notFound, validateRequest };