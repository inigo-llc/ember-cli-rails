import { ActiveModelSerializer } from 'active-model-adapter';

export function getHasManyPayloadKey(key) {
  const singularKey = Ember.Inflector.inflector.singularize(key);
  const underscoredKey = Ember.String.underscore(singularKey);
  return `${underscoredKey}_ids`;
}

export default ActiveModelSerializer.extend({
  attrs: {
    createdAt: { serialize: false },
    updatedAt: { serialize: false }
  },

  _getHasManyPayloadKey(key) {
    return getHasManyPayloadKey(key);
  },

  serializeHasMany(snapshot, json, relationship) {
    const key = relationship.key;

    json[this._getHasManyPayloadKey(key)] = snapshot.hasMany(
      key, { ids: true }
    );
  }
});
